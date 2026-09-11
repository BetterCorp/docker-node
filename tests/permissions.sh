#!/usr/bin/env bash
set -euo pipefail
image=${1:-betterweb/node:permission-test}
test "$(docker run --rm "$image" id -u)" = 1000
test "$(docker run --rm --user node "$image" id -u)" = 1000
test "$(docker run --rm --user 12345:12345 "$image" id -u)" = 12345
docker run --rm "$image" sh -c 'test ! -w /etc/passwd && test ! -w /usr/local/bin/node'
docker run --rm "$image" -e 'if (process.getuid() !== 1000) process.exit(1)'
test "$(docker run --rm "$image" sh -c 'printf "%s" "$1"' sh 'argument with spaces')" = 'argument with spaces'
echo 'Privilege dropping, non-root startup, filesystem restrictions and arguments passed.'
