#!/usr/bin/env bash
set -euo pipefail

POSTGRES_USER=$($DM_CREDENTIALS_REPO/sops-wrapper -d $DM_CREDENTIALS_REPO/db-cleanup/postgres-credentials.json | jq -r '.POSTGRES_USER') &> /dev/null
POSTGRES_PASSWORD=$($DM_CREDENTIALS_REPO/sops-wrapper -d $DM_CREDENTIALS_REPO/db-cleanup/postgres-credentials.json | jq -r '.POSTGRES_PASSWORD') &> /dev/null

cf ssh db-cleanup -N -L 63306:localhost:5432 &
TUNNEL_PID="$!"

sleep 10

ALEMBIC_VERSION=$(psql -qtA -d postgres://"${POSTGRES_USER}":"${POSTGRES_PASSWORD}"@localhost:63306/"${POSTGRES_USER}" -c 'SELECT version_num FROM alembic_version ORDER BY version_num DESC LIMIT 1')
echo "${ALEMBIC_VERSION}"

kill -9 "${TUNNEL_PID}"
