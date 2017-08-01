#!/bin/bash -e

LATEST_PROD_DUMP=$(aws s3 ls digitalmarketplace-database-backups | grep production | sort -r | head -1 | awk '{print $4}')
aws s3 cp s3://digitalmarketplace-database-backups/"${LATEST_PROD_DUMP}" ./"${LATEST_PROD_DUMP}"

gpg2 --batch --import <($DM_CREDENTIALS_REPO/sops-wrapper -d $DM_CREDENTIALS_REPO/gpg/database-backups/secret.key.enc)

SERVICE_DATA=$(cf curl /v3/apps/"$(cf app --guid db-cleanup)"/env | jq -r '.system_env_json.VCAP_SERVICES.postgres[0].credentials')
DB_HOST=$(echo $SERVICE_DATA | jq -r '.host')
DB_USERNAME=$(echo $SERVICE_DATA | jq -r '.username')
DB_PASSWORD=$(echo $SERVICE_DATA | jq -r '.password')
DB_NAME=$(echo $SERVICE_DATA | jq -r '.name')
DB_URI="postgres://${DB_USERNAME}:${DB_PASSWORD}@localhost:63306/${DB_NAME}"

cf ssh db-cleanup -N -L 63306:"$DB_HOST":5432 &
TUNNEL_PID="$!"

sleep 10

psql "${DB_URI}" < \
  <(echo -n $($DM_CREDENTIALS_REPO/sops-wrapper -d $DM_CREDENTIALS_REPO/gpg/database-backups/secret-key-passphrase.txt.enc) | \
  gpg2 --batch --passphrase-fd 0 --pinentry-mode loopback --decrypt ./"${LATEST_PROD_DUMP}" | \
  gunzip)

rm "${LATEST_PROD_DUMP}"

psql --variable bcrypt_password="'$(./scripts/generate-bcrypt-hashed-password.py Password1234 4)'" "${DB_URI}" < ./scripts/clean-db-dump.sql

kill -9 "${TUNNEL_PID}"
