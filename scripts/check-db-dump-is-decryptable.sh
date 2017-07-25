#!/usr/bin/env bash

aws s3 cp s3://digitalmarketplace-database-backups/${DUMP_FILE_NAME} ./${DUMP_FILE_NAME}
gpg2 --batch --import <($DM_CREDENTIALS_REPO/sops-wrapper -d $DM_CREDENTIALS_REPO/gpg/database-backups/secret.key.enc)
echo -n $($DM_CREDENTIALS_REPO/sops-wrapper -d $DM_CREDENTIALS_REPO/gpg/database-backups/secret-key-passphrase.txt.enc) | gpg2 --batch --passphrase-fd 0 --pinentry-mode loopback --list-packets ./${DUMP_FILE_NAME}
EXIT_CODE=$?

if [ ${EXIT_CODE} -gt 0 ]; then
  echo 'Decrpytion failed'
else
  echo 'Decryption succeeded'
fi

gpg2 --list-secret-keys --with-colons --fingerprint | grep fpr | cut -c 13-52 | xargs -n1 gpg2 --batch --delete-secret-key
rm ./${DUMP_FILE_NAME}

exit ${EXIT_CODE}
