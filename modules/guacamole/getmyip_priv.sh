#!/bin/bash
set -e
#only works for cloud 9 instance
INTERNETIP="$(ip addr show ens5 | grep 'inet ' | cut -d '/' -f 1 | tr -s " " | cut  -d ' ' -f 3)"
echo $(jq -n --arg internetip "$INTERNETIP" '{"internet_ip":$internetip}')