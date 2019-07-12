#!/usr/bin/env bash
set -euo pipefail

POSTGRES_URI=postgres://postgres:@localhost:63306/postgres

LATEST_PROD_DUMP=$(aws s3 ls digitalmarketplace-database-backups | grep production | sort -r | head -1 | awk '{print $4}')
aws s3 cp s3://digitalmarketplace-database-backups/"${LATEST_PROD_DUMP}" ./"${LATEST_PROD_DUMP}"

gpg2 --batch --import <($DM_CREDENTIALS_REPO/sops-wrapper -d $DM_CREDENTIALS_REPO/gpg/database-backups/secret.key.enc)

echo -n $($DM_CREDENTIALS_REPO/sops-wrapper -d $DM_CREDENTIALS_REPO/gpg/database-backups/secret-key-passphrase.txt.enc) | \
  gpg2 --batch --passphrase-fd 0 --pinentry-mode loopback --decrypt ./"${LATEST_PROD_DUMP}" | \
  gunzip | \
  psql "${POSTGRES_URI}"

gpg2 --list-secret-keys --with-colons --fingerprint | grep sec -A 1 | grep fpr | cut -c 13-52 | xargs -n1 gpg2 --batch --yes --pinentry-mode loopback --delete-secret-key
rm "${LATEST_PROD_DUMP}"

psql --single-transaction --variable bcrypt_password="'$(${VIRTUALENV_ROOT}/bin/python ./scripts/generate-bcrypt-hashed-password.py Password1234 12)'" "${POSTGRES_URI}" < ./scripts/clean-db-dump.sql
