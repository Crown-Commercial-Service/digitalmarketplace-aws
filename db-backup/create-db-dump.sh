#!/usr/bin/env bash
set -euxo pipefail

set +x  # Don't log credentials
DB_URI=$(echo $VCAP_SERVICES | jq -r '.postgres[0].credentials.uri')
set -x  # Restore logging
echo -n "${PUBKEY}" > /app/public.key
gpg2 --import /app/public.key
pg_dump "${DB_URI}" --no-acl --no-owner --clean --if-exists | gzip | \
  gpg2 --trust-model always -r "${RECIPIENT}" --out /app/"${DUMP_FILE_NAME}" --encrypt

/usr/local/bin/python /app/upload-dump-to-s3.py
