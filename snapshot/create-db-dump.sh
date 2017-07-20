#!/usr/bin/env bash
set -euxo pipefail

DB_URI=$(echo $VCAP_SERVICES | jq -r '.postgres[0].credentials.uri')
OUTFILE_NAME=$(date +"%Y%m%d%H%M")

pg_dump "${DB_URI}" --no-acl --no-owner | gzip | \
  gpg2 --trust-model always -a -r 'Digital Marketplace DB backups' --out "${OUTFILE_NAME}".sql.gz.gpg --encrypt

DUMP_FILE="${OUTFILE_NAME}".sql.gz.gpg python upload-dump-to-s3.py
