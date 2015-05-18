#!/bin/bash

set -e

cd "$(dirname "$0")/.."

find_repos () {
  ls -d ../*/.git | cut -d/ -f2 | grep '^digital-\?marketplace'
}

find_repos | xargs -P8 -n1 ./scripts/single-update-git.sh
