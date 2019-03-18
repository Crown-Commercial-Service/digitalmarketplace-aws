#!/usr/bin/env bash
set -euo pipefail

echo "Target is: ${TARGET}"

mkdir -p ./dumps
pg_dump --no-acl --no-owner --clean postgres://postgres:@localhost:63306/postgres | gzip > cleaned-db-dump.sql.gz

if [ "${TARGET}" == 's3' ]; then
  echo 'Uploading cleaned dump to S3'
elif [ "${TARGET}" == 'preview' ] || [ "${TARGET}" == 'staging' ]; then
  echo "Migrating cleaned dump to ${TARGET} and uploading to S3 bucket"
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

  psql "${TARGET_DB_URI}" < <(gunzip --to-stdout cleaned-db-dump.sql.gz)
  kill -9 "${TARGET_TUNNEL_PID}"
else
  echo 'Error: Unknown variable `TARGET`. Valid choices are `s3`, `preview`, `staging`'
  rm -fr ./cleaned-db-dump.sql.gz
  exit 1
fi

aws s3 cp --acl bucket-owner-full-control ./cleaned-db-dump.sql.gz s3://digitalmarketplace-cleaned-db-dumps

rm -fr ./cleaned-db-dump.sql.gz
