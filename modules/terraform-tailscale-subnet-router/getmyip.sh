#!/bin/bash
set -e
#INTERNETIP="$(dig +short myip.opendns.com @resolver1.opendns.com -4)"
#INTERNETIP="$(curl -s ifconfig.me)"
INTERNETIP="$(curl -4 icanhazip.com)"
echo $(jq -n --arg internetip "$INTERNETIP" '{"internet_ip":$internetip}')
