#!/usr/bin/env bash
set -euo pipefail

cf target -s preview
DB_PLAN=$(cf service digitalmarketplace_api_db | grep -i 'plan: ' | cut -d ' ' -f2)
cf target -s db-cleanup
[ $(cf target | grep -i 'space' | cut -d':' -f2) = "db-cleanup" ] || (echo "Error: This can only be run in the db-cleanup space" && exit 1)
cf create-service postgres ${DB_PLAN} digitalmarketplace_db_cleanup
