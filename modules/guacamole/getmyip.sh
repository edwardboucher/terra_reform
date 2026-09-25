#!/bin/bash
set -euo pipefail

get_ip() {
  local ip
  for url in https://checkip.amazonaws.com https://api.ipify.org https://ifconfig.me/ip https://icanhazip.com; do
    ip="$(curl -4 -sSf --max-time 5 "$url" 2>/dev/null | tr -d '[:space:]')" || continue
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then echo "$ip"; return 0; fi
  done
  # DNS fallback (works if HTTP is filtered but DNS egress is open)
  ip="$(dig +short -4 TXT o-o.myaddr.l.google.com @ns1.google.com 2>/dev/null | tr -d '"')"
  [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] && { echo "$ip"; return 0; }
  return 1
}

INTERNETIP="$(get_ip)" || { echo "Could not determine public IP" >&2; exit 1; }
jq -n --arg internetip "$INTERNETIP" '{"internet_ip":$internetip}'