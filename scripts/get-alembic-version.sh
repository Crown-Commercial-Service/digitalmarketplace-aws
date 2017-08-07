#!/usr/bin/env bash
set -euo pipefail

SERVICE_DATA=$(cf curl /v3/apps/"$(cf app --guid db-cleanup)"/env | jq -r '.system_env_json.VCAP_SERVICES.postgres[0].credentials')
DB_HOST=$(echo $SERVICE_DATA | jq -r '.host')
DB_USERNAME=$(echo $SERVICE_DATA | jq -r '.username')
DB_PASSWORD=$(echo $SERVICE_DATA | jq -r '.password')
DB_NAME=$(echo $SERVICE_DATA | jq -r '.name')
DB_URI="postgres://${DB_USERNAME}:${DB_PASSWORD}@localhost:63306/${DB_NAME}"

cf ssh db-cleanup -N -L 63306:"$DB_HOST":5432 &
TUNNEL_PID="$!"

sleep 10

ALEMBIC_VERSION=$(psql -qtA -d ${DB_URI} -c 'SELECT version_num FROM alembic_version ORDER BY version_num DESC LIMIT 1')
echo "${ALEMBIC_VERSION}"

kill -9 "${TUNNEL_PID}"
