#!/usr/bin/env bash
## Not currently in use.

set -e

PLEX_VERSION="$(
  curl -fsSL https://plex.tv/api/downloads/5.json |
    tr -d '\r\n' |
    jq -r '.computer.Linux.releases[] | select(.distro == "debian" and .build == "linux-x86_64") | .url | split("/") | last' |
    sed -E 's@^plexmediaserver_([^-]+[^_]+).*$@\1@'
)"

echo "PLEX_VERSION=$PLEX_VERSION"

sed -Ei \
  -e "s/^(ARG PLEX_VER=).*$/\1$PLEX_VERSION/" \
  Dockerfile
