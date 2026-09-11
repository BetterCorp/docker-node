#!/bin/sh
set -e

if [ "$#" -eq 0 ]; then
  set -- node
fi

# Run command with node if the first argument contains a "-" or is not a system command. The last
# part inside the "{}" is a workaround for the following bug in ash/dash:
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=874264
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ] || { [ -f "${1}" ] && ! [ -x "${1}" ]; }; then
  set -- node "$@"
fi

# Keep the privilege drop when Docker starts us as root. Already-unprivileged
# containers (USER node / --user) must not attempt a forbidden setgroups call.
if [ "$(id -u)" = "0" ]; then
  exec gosu node:node "$@"
fi
exec "$@"
