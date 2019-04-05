#!/bin/bash -e

if [ "$#" -ne 2 ]; then
    echo "Usage: ./scripts/map-route.sh <application_name> <manifest_file>"
    exit 1
fi

APPLICATION_NAME="$1"
MANIFEST_FILE="$2"

APP_ROUTES="$(yq '.applications[] | {(.name): .routes}' ${MANIFEST_FILE})"

for ROUTE in $(echo $APP_ROUTES | jq -c '.["'${APPLICATION_NAME}'"] | .[]'); do
  # use jq regex power to split url into component parts
  MATCH=$(jq '.route | capture("^((?<host>[a-z_-]*).)?(?<domain>[a-z_.-]*)(?<path>[a-z_/-]*)?$")' <<< $ROUTE)

  URL_DOMAIN=$(jq -r '.domain' <<< $MATCH)
  URL_HOST=$(jq -r '.host' <<< $MATCH)
  URL_PATH=$(jq -r '.path' <<< $MATCH)

  ARGS="$APPLICATION_NAME $URL_DOMAIN"
  [ -n "$URL_HOST" ] && ARGS="$ARGS --hostname $URL_HOST"
  [ -n "$URL_PATH" ] && ARGS="$ARGS --path $URL_PATH"

  echo cf map-route $ARGS
  cf map-route $ARGS
done
