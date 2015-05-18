#!/usr/bin/env sh

set -e

ANSI_GREEN="\033[32m"
ANSI_RED="\033[31m"
ANSI_YELLOW="\033[33m"
ANSI_RESET="\033[0m"
ANSI_BOLD="\033[1m"

truncate () {
  local len="$1"
  local str="$2"
  if [ "${#str}" -gt "$len" ]; then
    printf "$str" | awk "{ s=substr(\$0, 1, $len-3); print s \"...\"; }"
  else
    printf "$str"
  fi
}

start () {
  local repo="$1"
  local branch="$2"
  repo=$(truncate 40 "$repo")
  branch=$(truncate 30 "$branch")
  printf "${ANSI_BOLD}%-40s${ANSI_RESET} %-30s " "$repo" "$branch" >&2
}

ok () {
  start "$REPO" "$BRANCH"
  printf "${ANSI_GREEN}%s${ANSI_RESET}\n" "$@" >&2
}

warn () {
  start "$REPO" "$BRANCH"
  echo "${ANSI_YELLOW}${@}${ANSI_RESET}" >&2
}

error () {
  start "$REPO" "$BRANCH"
  echo "${ANSI_RED}${@}${ANSI_RESET}" >&2
}

catch_errors () {
  out=$(mktemp -t update-git.XXXXXX)
  trap "rm -f '$out'" EXIT

  if ! "$@" >"$out" 2>&1; then
    error "FAILED, with output:"
    cat "$out"
    exit 1
  fi

  rm -f "$out"
}

################

cd "$(dirname "$0")/.."

REPO="$1"

cd ../$1

BRANCH="$(git symbolic-ref HEAD | sed 's|^refs/heads/||')"

if [ "$BRANCH" != "master" ]; then
  warn "skipped: on non-master branch"
elif ! git diff --quiet --ignore-submodules --no-ext-diff; then
  warn "skipped: uncommitted local changes"
else
  catch_errors git fetch origin
  if ! git merge --ff-only origin/master > /dev/null 2>&1; then
    warn "skipped: unpushed local commits"
  else
    ok "ok"
  fi
fi
