#!/bin/bash -e

if [ "$#" -ne 1 ]; then
    echo "This script uses the variables in vars/ip_whitelist_routes.json to ip whitelist routes using the re-ip-whitelist-service."
    echo ""
    echo "Usage: ./scripts/add-ip-whitelist-route-service.sh <stage>"
    exit 1
fi

STAGE=$( echo $1 | awk '{ print tolower($0) }' )

IFS=$'\n'
for HOSTNAME_PATH in $(jq -r ".${STAGE}[] | \"\(.hostname) \(.path)\"" vars/ip_whitelist_routes.json); do
    HOSTNAME=$(echo $HOSTNAME_PATH | cut -f1 -d" ")
    PATH=$(echo $HOSTNAME_PATH | cut -f2 -d" ")
    echo cf bind-route-service cloudapps.digital re-ip-whitelist-service --hostname $HOSTNAME --path $PATH
    cf bind-route-service cloudapps.digital re-ip-whitelist-service --hostname $HOSTNAME --path $PATH
done
