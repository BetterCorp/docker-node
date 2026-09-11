#!/bin/sh
set -eu
if [ "$#" -eq 0 ]; then
  echo 'Usage: install_packages package [package ...]' >&2
  exit 2
fi
apk add --no-cache --virtual .betterweb-gyp python3 make g++
trap 'apk del .betterweb-gyp' EXIT
npm install "$@"
