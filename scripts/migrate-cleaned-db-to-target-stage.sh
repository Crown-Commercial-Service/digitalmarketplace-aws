#!/usr/bin/env bash
set -euo pipefail

echo "Target stage is: ${TARGET_STAGE}"

CLEANUP_SERVICE_DATA=$(cf curl /v3/apps/"$(cf app --guid db-cleanup)"/env | jq -r '.system_env_json.VCAP_SERVICES.postgres[0].credentials')
CLEANUP_DB_HOST=$(echo "${CLEANUP_SERVICE_DATA}" | jq -r '.host')
CLEANUP_DB_USERNAME=$(echo "${CLEANUP_SERVICE_DATA}" | jq -r '.username')
CLEANUP_DB_PASSWORD=$(echo "${CLEANUP_SERVICE_DATA}" | jq -r '.password')
CLEANUP_DB_NAME=$(echo "${CLEANUP_SERVICE_DATA}" | jq -r '.name')
CLEANUP_DB_URI="postgres://${CLEANUP_DB_USERNAME}:${CLEANUP_DB_PASSWORD}@localhost:63306/${CLEANUP_DB_NAME}"

cf ssh db-cleanup -N -L 63306:"${CLEANUP_DB_HOST}":5432 &
CLEANUP_TUNNEL_PID="$!"
sleep 10

mkdir ./dumps
LATEST_PROD_DUMP=$(aws s3 ls digitalmarketplace-database-backups | grep production | sort -r | head -1 | awk '{print $4}')
pg_dump --no-acl --no-owner --clean "${CLEANUP_DB_URI}" | gzip > ./dumps/cleaned-"${LATEST_PROD_DUMP%.*}"

kill -9 "${CLEANUP_TUNNEL_PID}"

if [ "${TARGET_STAGE}" == 'google-drive' ]; then
  echo 'Uploading cleaned dump to Google Drive'
elif [ "${TARGET_STAGE}" == 'preview' ] || [ "${TARGET_STAGE}" == 'staging' ]; then
  echo "Migrating cleaned dump to ${TARGET_STAGE} and uploading to Google Drive"
  cf target -s ${TARGET_STAGE}
  TARGET_SERVICE_DATA=$(cf curl /v3/apps/"$(cf app --guid api)"/env | jq -r '.system_env_json.VCAP_SERVICES.postgres[0].credentials')
  TARGET_DB_HOST=$(echo "${TARGET_SERVICE_DATA}" | jq -r '.host')
  TARGET_DB_USERNAME=$(echo "${TARGET_SERVICE_DATA}" | jq -r '.username')
  TARGET_DB_PASSWORD=$(echo "${TARGET_SERVICE_DATA}" | jq -r '.password')
  TARGET_DB_NAME=$(echo "${TARGET_SERVICE_DATA}" | jq -r '.name')
  TARGET_DB_URI="postgres://${TARGET_DB_USERNAME}:${TARGET_DB_PASSWORD}@localhost:63306/${TARGET_DB_NAME}"

  cf ssh api -N -L 63306:"${TARGET_DB_HOST}":5432 &
  TARGET_TUNNEL_PID="$!"
  sleep 10

  psql "${TARGET_DB_URI}" < <(gunzip --to-stdout ./dumps/cleaned-"${LATEST_PROD_DUMP%.*}")
  kill -9 "${TARGET_TUNNEL_PID}"
  cf target -s db-cleanup
else
  echo 'Error: Unknown variable `TARGET_STAGE`. Valid choices are `google-drive`, `preview`, `staging`'
  rm -fr ./dumps
  exit 1
fi

/usr/local/bin/gdrive --config "/var/lib/jenkins/.gdrive" sync upload --delete-extraneous ./dumps "${GDRIVE_EXPORTDATA_FOLDER_ID}"

rm -fr ./dumps
