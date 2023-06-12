#!/bin/bash
set -e

RELEASE="$(curl -fsSL https://api.spritsail.io/plex/release | jq -c)"
VERSION="$(jq -r .version <<<"$RELEASE")"
CHECKSUM="$(jq -r '.["csum-deb"]' <<<"$RELEASE")"

# If running on macOS, use gsed instead of sed
if [[ "$(uname -s)" == "Darwin" ]]; then
  if ! command -v gsed >/dev/null; then
    echo >&2 "gsed not found"
    exit 1
  fi
  sed() {
    gsed "$@"
  }
fi

sed -Ei \
  -e "s/^(ARG PLEX_VER=).*$/\1$VERSION/" \
  -e "s/^(ARG PLEX_SHA=).*$/\1$CHECKSUM/" \
  Dockerfile

if ! git diff --quiet --exit-code Dockerfile; then

  echo "Updating to Plex $VERSION" >>"$GITHUB_STEP_SUMMARY"

  export GIT_COMMITTER_NAME="Plex Updater Bot"
  export GIT_COMMITTER_EMAIL="plex-updater@noreply.github.com"
  export GIT_AUTHOR_NAME="$GIT_COMMITTER_NAME"
  export GIT_AUTHOR_EMAIL="$GIT_COMMITTER_EMAIL"
  git reset --soft
  git add -- Dockerfile
  git commit \
    --no-gpg-sign \
    --signoff \
    -m "Update to Plex ${VERSION%-*}"
  git push origin HEAD
  PLEX_UPDATED=true
else
  echo >&2 No plex updates to install
  PLEX_UPDATED=false
fi

echo "PLEX_UPDATED=${PLEX_UPDATED}" >>"$GITHUB_ENV"
