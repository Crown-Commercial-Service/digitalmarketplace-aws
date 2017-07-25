#!/usr/bin/env bash
set -euxo pipefail

DB_URI=$(echo $VCAP_SERVICES | jq -r '.postgres[0].credentials.uri')

pg_dump "${DB_URI}" --no-acl --no-owner | gzip | \
  gpg2 --trust-model always -a -r 'Digital Marketplace DB backups' --out /app/dump.sql.gz.gpg --encrypt

/usr/local/bin/python /app/upload-dump-to-s3.py
