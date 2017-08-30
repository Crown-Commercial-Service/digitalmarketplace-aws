#!/bin/bash -e

if [ "$#" -ne 1 ]; then
    echo "Usage: ./scripts/unmap-route.sh <application_name>"
    exit 1
fi

APPLICATION_NAME=$1
APP_GUID=$(cf app --guid ${APPLICATION_NAME})

ROUTE_URLS=$(cf curl /v2/apps/${APP_GUID}/route_mappings | jq -r '.resources[].entity.route_url')

for ROUTE_URL in ${ROUTE_URLS}; do
  ROUTE_DATA=$(cf curl ${ROUTE_URL} | jq '.entity')

  ROUTE_HOST=$(echo $ROUTE_DATA | jq -r '.host')
  ROUTE_PATH=$(echo $ROUTE_DATA | jq -r '.path')

  echo "Unmapping ${ROUTE_HOST}.cloudapps.digital/${ROUTE_PATH} from ${APPLICATION_NAME}"

  cf unmap-route "${APPLICATION_NAME}" cloudapps.digital --hostname "${ROUTE_HOST}" --path "${ROUTE_PATH}"
done
