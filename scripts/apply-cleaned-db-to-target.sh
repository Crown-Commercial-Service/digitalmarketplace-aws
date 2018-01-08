#!/usr/bin/env bash
set -euo pipefail

echo "Target is: ${TARGET}"

mkdir -p ./dumps
LATEST_PROD_DUMP=$(aws s3 ls digitalmarketplace-database-backups | grep production | sort -r | head -1 | awk '{print $4}')
pg_dump --no-acl --no-owner --clean postgres://postgres:@localhost:63306/postgres | gzip > ./dumps/cleaned-"${LATEST_PROD_DUMP%.*}"

if [ "${TARGET}" == 'google-drive' ]; then
  echo 'Uploading cleaned dump to Google Drive'
elif [ "${TARGET}" == 'preview' ] || [ "${TARGET}" == 'staging' ]; then
  echo "Migrating cleaned dump to ${TARGET} and uploading to Google Drive"
  cf target -s ${TARGET}
  TARGET_SERVICE_DATA=$(cf curl /v3/apps/"$(cf app --guid api)"/env | jq -r '.system_env_json.VCAP_SERVICES.postgres[0].credentials')
  TARGET_DB_HOST=$(echo "${TARGET_SERVICE_DATA}" | jq -r '.host')
  TARGET_DB_USERNAME=$(echo "${TARGET_SERVICE_DATA}" | jq -r '.username')
  TARGET_DB_PASSWORD=$(echo "${TARGET_SERVICE_DATA}" | jq -r '.password')
  TARGET_DB_NAME=$(echo "${TARGET_SERVICE_DATA}" | jq -r '.name')
  TARGET_DB_URI="postgres://${TARGET_DB_USERNAME}:${TARGET_DB_PASSWORD}@localhost:63307/${TARGET_DB_NAME}"

  cf ssh api -N -L 63307:"${TARGET_DB_HOST}":5432 &
  TARGET_TUNNEL_PID="$!"
  sleep 10

  psql "${TARGET_DB_URI}" < <(gunzip --to-stdout ./dumps/cleaned-"${LATEST_PROD_DUMP%.*}")
  kill -9 "${TARGET_TUNNEL_PID}"
else
  echo 'Error: Unknown variable `TARGET`. Valid choices are `google-drive`, `preview`, `staging`'
  rm -fr ./dumps
  exit 1
fi

/usr/local/bin/gdrive --config "/var/lib/jenkins/.gdrive" sync upload --delete-extraneous ./dumps "${GDRIVE_EXPORTDATA_FOLDER_ID}"

rm -fr ./dumps
