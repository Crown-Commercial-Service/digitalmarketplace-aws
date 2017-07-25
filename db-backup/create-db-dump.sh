#!/usr/bin/env bash
set -euxo pipefail

DB_URI=$(echo $VCAP_SERVICES | jq -r '.postgres[0].credentials.uri')
echo -n "${PUBKEY}" > /app/public.key
gpg2 --import /app/public.key
pg_dump "${DB_URI}" --no-acl --no-owner | gzip | \
  gpg2 --trust-model always -r "${RECIPIENT}" --out /app/dump.sql.gz.gpg --encrypt

/usr/local/bin/python /app/upload-dump-to-s3.py
