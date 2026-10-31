#!/bin/bash
# Syncs Guacamole connections via the REST API, driven by a JSON definitions
# file. Connections are kept in a dedicated connection group
# ($GUAC_MANAGED_GROUP, default "AWS Instances"): entries are matched by name
# within that group and updated in place, and any connection in the group that
# is no longer in the file is deleted. Safe to re-run on every deploy.
#
# Usage: guac_add_connections.sh <admin_user> <admin_pass> <connections.json>
#
# connections.json format:
# [
#   {
#     "name": "web-01 (RDP)",
#     "protocol": "rdp",
#     "parameters": {
#       "hostname": "10.0.1.23",
#       "port": "3389",
#       "username": "Administrator",
#       "password": "changeme",
#       "security": "any",
#       "ignore-cert": "true"
#     }
#   },
#   {
#     "name": "bastion-01 (SSH)",
#     "protocol": "ssh",
#     "parameters": {
#       "hostname": "10.0.2.10",
#       "port": "22",
#       "username": "ec2-user",
#       "private-key": "-----BEGIN OPENSSH PRIVATE KEY-----\n..."
#     }
#   }
# ]

set -euo pipefail

GUAC_ADMIN_USER="${1:?usage: $0 <admin_user> <admin_pass> <connections_json_path>}"
GUAC_ADMIN_PASS="${2:?usage: $0 <admin_user> <admin_pass> <connections_json_path>}"
CONNECTIONS_FILE="${3:?usage: $0 <admin_user> <admin_pass> <connections_json_path>}"

# nginx terminates TLS with a self-signed cert and proxies straight through
# to the guacamole container's /guacamole/ path (see nginx.conf.template),
# so the API root as seen from the host is https://localhost:8443/api.
GUAC_BASE_URL="${GUAC_BASE_URL:-https://localhost:8443}"
CURL=(curl -sk)

# Retry the login itself rather than probing for any HTTP response: nginx
# answers (502) well before the guacamole webapp and its DB schema are ready.
echo "Waiting for Guacamole API and authenticating as ${GUAC_ADMIN_USER}..."
AUTH_TOKEN=""
for i in $(seq 1 60); do
  AUTH_RESPONSE=$("${CURL[@]}" -X POST \
    --data-urlencode "username=${GUAC_ADMIN_USER}" \
    --data-urlencode "password=${GUAC_ADMIN_PASS}" \
    "${GUAC_BASE_URL}/api/tokens" || true)
  AUTH_TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.authToken // empty' 2>/dev/null || true)
  if [ -n "$AUTH_TOKEN" ]; then
    break
  fi
  sleep 5
done

DATA_SOURCE=$(echo "$AUTH_RESPONSE" | jq -r '.dataSource // empty')

if [ -z "$AUTH_TOKEN" ]; then
  echo "Failed to authenticate to Guacamole: $AUTH_RESPONSE" >&2
  exit 1
fi

API="${GUAC_BASE_URL}/api/session/data/${DATA_SOURCE}"

# Managed connections live in their own connection group so connections that
# were added by hand in the UI are never updated or deleted by this script.
GUAC_MANAGED_GROUP="${GUAC_MANAGED_GROUP:-AWS Instances}"
GROUP_ID=$("${CURL[@]}" "${API}/connectionGroups?token=${AUTH_TOKEN}" | jq -r --arg name "$GUAC_MANAGED_GROUP" \
  'to_entries[] | select(.value.name == $name and .value.parentIdentifier == "ROOT") | .key' | head -n1)

if [ -z "$GROUP_ID" ]; then
  echo "Creating connection group '${GUAC_MANAGED_GROUP}'"
  GROUP_ID=$(jq -n --arg name "$GUAC_MANAGED_GROUP" \
    '{parentIdentifier: "ROOT", name: $name, type: "ORGANIZATIONAL", attributes: {}}' |
    "${CURL[@]}" -X POST -H "Content-Type: application/json" -d @- \
      "${API}/connectionGroups?token=${AUTH_TOKEN}" | jq -r '.identifier // empty')
  if [ -z "$GROUP_ID" ]; then
    echo "Failed to create connection group '${GUAC_MANAGED_GROUP}'" >&2
    exit 1
  fi
fi

# Snapshot the group's existing connections once so repeated runs update in
# place by name instead of piling up duplicates.
EXISTING=$("${CURL[@]}" "${API}/connections?token=${AUTH_TOKEN}" | jq --arg gid "$GROUP_ID" \
  'with_entries(select(.value.parentIdentifier == $gid))')

# Remove connections in the managed group that are no longer in the file
# (instance dropped from guac_target_instances, or renamed).
echo "$EXISTING" | jq -r --slurpfile want "$CONNECTIONS_FILE" \
  '($want[0] | map(.name)) as $names | to_entries[] | select(.value.name as $n | $names | index($n) | not) | "\(.key)\t\(.value.name)"' |
  while IFS=$'\t' read -r STALE_ID STALE_NAME; do
    echo "Deleting connection '${STALE_NAME}' (id=${STALE_ID})"
    "${CURL[@]}" -X DELETE "${API}/connections/${STALE_ID}?token=${AUTH_TOKEN}"
    echo
  done

jq -c '.[]' "$CONNECTIONS_FILE" | while read -r conn; do
  NAME=$(echo "$conn" | jq -r '.name')
  EXISTING_ID=$(echo "$EXISTING" | jq -r --arg name "$NAME" \
    'to_entries[] | select(.value.name == $name) | .key' | head -n1)

  BODY=$(echo "$conn" | jq --arg gid "$GROUP_ID" '{
    parentIdentifier: $gid,
    name: .name,
    protocol: .protocol,
    parameters: .parameters,
    attributes: {}
  }')

  if [ -n "$EXISTING_ID" ]; then
    echo "Updating connection '${NAME}' (id=${EXISTING_ID})"
    BODY=$(echo "$BODY" | jq --arg id "$EXISTING_ID" '. + {identifier: $id}')
    "${CURL[@]}" -X PUT \
      -H "Content-Type: application/json" \
      -d "$BODY" \
      "${API}/connections/${EXISTING_ID}?token=${AUTH_TOKEN}"
  else
    echo "Creating connection '${NAME}'"
    "${CURL[@]}" -X POST \
      -H "Content-Type: application/json" \
      -d "$BODY" \
      "${API}/connections?token=${AUTH_TOKEN}"
  fi
  echo
done

echo "done"
