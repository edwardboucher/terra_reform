#!/bin/bash
# Creates/updates Guacamole connections via the REST API, driven by a JSON
# definitions file. Matches existing connections by name, so it is safe to
# re-run (e.g. on every deploy) without creating duplicates.
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

echo "Waiting for Guacamole API to come up..."
for i in $(seq 1 30); do
  code=$("${CURL[@]}" -o /dev/null -w '%{http_code}' "${GUAC_BASE_URL}/api/tokens" || true)
  # a real response (even a 400 for a bad/empty POST) means the app is serving requests
  if [ "$code" != "000" ]; then
    break
  fi
  sleep 5
done

echo "Authenticating as ${GUAC_ADMIN_USER}..."
AUTH_RESPONSE=$("${CURL[@]}" -X POST \
  --data-urlencode "username=${GUAC_ADMIN_USER}" \
  --data-urlencode "password=${GUAC_ADMIN_PASS}" \
  "${GUAC_BASE_URL}/api/tokens")

AUTH_TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.authToken // empty')
DATA_SOURCE=$(echo "$AUTH_RESPONSE" | jq -r '.dataSource // empty')

if [ -z "$AUTH_TOKEN" ]; then
  echo "Failed to authenticate to Guacamole: $AUTH_RESPONSE" >&2
  exit 1
fi

API="${GUAC_BASE_URL}/api/session/data/${DATA_SOURCE}"

# Snapshot existing connections once so repeated runs update in place by name
# instead of piling up duplicates.
EXISTING=$("${CURL[@]}" "${API}/connections?token=${AUTH_TOKEN}")

jq -c '.[]' "$CONNECTIONS_FILE" | while read -r conn; do
  NAME=$(echo "$conn" | jq -r '.name')
  EXISTING_ID=$(echo "$EXISTING" | jq -r --arg name "$NAME" \
    'to_entries[] | select(.value.name == $name) | .key' | head -n1)

  BODY=$(echo "$conn" | jq '{
    parentIdentifier: "ROOT",
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
