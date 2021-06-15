#!/bin/bash -e

if [ "$#" -ne 2 ]; then
    echo "This script uses the variables in vars/ip_allowlist_routes.json to ip allow list routes using the GOV.UK PaaS IP authentication route service"
    echo ""
    echo "Usage: ./scripts/add-ip-allowlist-route-service.sh <STAGE> <APPLICATION_NAME>"
    exit 1
fi

export STAGE=$( echo $1 | awk '{ print tolower($0) }' )
export APPLICATION_NAME=$( echo $2 | awk '{ print tolower($0) }' )

IFS=$'\n'
for HOSTNAME_PATH in $(jq -r '.[env.STAGE][env.APPLICATION_NAME][] | "\(.hostname) \(.path)"' vars/ip_allowlist_routes.json); do
  HOSTNAME=$(echo $HOSTNAME_PATH | cut -f1 -d" ")
  ROUTE_PATH=$(echo $HOSTNAME_PATH | cut -f2 -d" ")
  echo cf bind-route-service cloudapps.digital re-ip-allowlist-service --hostname $HOSTNAME --path $ROUTE_PATH
  cf bind-route-service cloudapps.digital re-ip-allowlist-service --hostname $HOSTNAME --path $ROUTE_PATH
done
