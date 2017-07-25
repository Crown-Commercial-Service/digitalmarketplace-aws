#!/usr/bin/env bash

LATEST_DUMP=$(aws s3 ls s3://digitalmarketplace-database-backups | sort | tail -n 1 | awk '{print $4}')
aws s3 cp s3://digitalmarketplace-database-backups/${LATEST_DUMP} ./latest-dump.sql.gz.gpg
gpg2 --batch --import <($DM_CREDENTIALS_REPO/sops-wrapper -d $DM_CREDENTIALS_REPO/gpg/database-backups/secret.key.enc)
echo -n $($DM_CREDENTIALS_REPO/sops-wrapper -d $DM_CREDENTIALS_REPO/gpg/database-backups/secret-key-passphrase.txt.enc) | gpg2 --batch --passphrase-fd 0 --pinentry-mode loopback --list-packets ./latest-dump.sql.gz.gpg
EXIT_CODE=$?

if [ ${EXIT_CODE} -gt 0 ]; then
  echo 'Decrpytion failed'
else
  echo 'Decryption succeeded'
fi

gpg2 --list-secret-keys --with-colons --fingerprint | grep fpr | cut -c 13-52 | xargs -n1 gpg2 --batch --delete-secret-key
rm ./latest-dump.sql.gz.gpg

exit ${EXIT_CODE}
