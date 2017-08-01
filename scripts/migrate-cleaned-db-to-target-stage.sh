#!/usr/bin/env bash

SERVICE_DATA=$(cf curl /v3/apps/"$(cf app --guid db-cleanup)"/env | jq -r '.system_env_json.VCAP_SERVICES.postgres[0].credentials')
DB_HOST=$(echo "${SERVICE_DATA}" | jq -r '.host')
DB_USERNAME=$(echo "${SERVICE_DATA}" | jq -r '.username')
DB_PASSWORD=$(echo "${SERVICE_DATA}" | jq -r '.password')
DB_NAME=$(echo "${SERVICE_DATA}" | jq -r '.name')
DB_URI="postgres://${DB_USERNAME}:${DB_PASSWORD}@localhost:63306/${DB_NAME}"

cf ssh db-cleanup -N -L 63306:"${DB_HOST}":5432 &
TUNNEL_PID="$!"

sleep 10

mkdir ./dumps
LATEST_PROD_DUMP=$(aws s3 ls digitalmarketplace-database-backups | grep production | sort -r | head -1 | awk '{print $4}')
pg_dump --no-acl --no-owner --clean "${DB_URI}" | gzip > ./dumps/cleaned-"${LATEST_PROD_DUMP%.*}"

/usr/local/bin/gdrive --config "/var/lib/jenkins/.gdrive" sync upload --delete-extraneous ./dumps "${GDRIVE_EXPORTDATA_FOLDER_ID}"

rm -fr ./dumps

kill -9 "${TUNNEL_PID}"
