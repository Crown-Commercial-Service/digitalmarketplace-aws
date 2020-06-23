#!/usr/bin/env bash
set -euxo pipefail

echo -n "${PUBKEY}" > /app/public.key
gpg2 --import /app/public.key
pg_dump "${DATABASE_URL}" --no-acl --no-owner --clean --if-exists | gzip | \
  gpg2 --trust-model always -r "${RECIPIENT}" --out /app/"${DUMP_FILE_NAME}" --encrypt

/usr/local/bin/python /app/upload-dump-to-s3.py
