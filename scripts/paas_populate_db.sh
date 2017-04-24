#!/bin/bash -e

DB_DUMP=$1

cf create-service-key digitalmarketplace_api_db DATA_MIGRATION_KEY
KEY_DATA=$(cf curl /v2/service_keys/$(cf service-key digitalmarketplace_api_db DATA_MIGRATION_KEY --guid))
DB_HOST=$(echo $KEY_DATA | jq -r '.entity.credentials.host')
DB_PASSWORD=$(echo $KEY_DATA | jq -r '.entity.credentials.password')
DB_USERNAME=$(echo $KEY_DATA | jq -r '.entity.credentials.username')
DB_NAME=$(echo $KEY_DATA | jq -r '.entity.credentials.name')
(cf ssh-code | pbcopy)
ssh -f -o ExitOnForwardFailure=yes  -L 63306:$DB_HOST:5432 -p 2222 cf:$(cf app api --guid)/0@ssh.cloud.service.gov.uk sleep 10
psql -d postgresql://$DB_USERNAME:$DB_PASSWORD@localhost:63306/$DB_NAME < $DB_DUMP
cf delete-service-key digitalmarketplace_api_db DATA_MIGRATION_KEY
