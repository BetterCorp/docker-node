#!/usr/bin/env bash
set -euo pipefail

# Select the newest patch that actually exists in both upstream image variants.
# Node releases can precede Docker publication; never invent fallback platforms.
task_tmp=$(mktemp -d)
trap 'rm -rf "$task_tmp"' EXIT
curl -fsSL --retry 3 https://nodejs.org/download/release/index.json > "$task_tmp/releases.json"
rows='[]'
for major in 24 26; do
  found=false
  while read -r version; do
    if ! docker manifest inspect "node:${version}-alpine" > "$task_tmp/alpine.json" 2>/dev/null; then
      continue
    fi
    if ! docker manifest inspect "node:${version}-bookworm" > "$task_tmp/bookworm.json" 2>/dev/null; then
      continue
    fi
    if ! jq -e '[.manifests[].platform | select(.os == "linux") | .architecture] | index("amd64") != null and index("arm64") != null' "$task_tmp/alpine.json" >/dev/null; then
      continue
    fi
    rows=$(jq -c --arg v "v$version" --argjson m "$major" '. + [{version:$v, major:$m, platforms:"linux/amd64,linux/arm64/v8"}]' <<< "$rows")
    found=true
    break
  done < <(jq -r --argjson major "$major" '[.[].version | ltrimstr("v") | split(".") | map(tonumber) | select(.[0] == $major)] | sort | reverse | .[] | map(tostring) | join(".")' "$task_tmp/releases.json")
  if [ "$found" = false ]; then
    echo "No published upstream images for Node $major" >&2
    exit 1
  fi
done
echo "matrix=$(jq -c '{tag:.}' <<< "$rows")"
echo "latest=$(jq -r 'max_by(.major).version' <<< "$rows")"
