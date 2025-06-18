rm -f node_versions.json node_versions_recent.json versions.json config.json

curl -s "https://nodejs.org/download/release/index.json" > node_versions.json

# Filter out versions older than 2 years
two_years_ago=$(date -u -d "2 years ago" +%s)
jq --argjson two_years_ago "$two_years_ago" '[.[] | select((.date | sub("T.*"; "") | strptime("%Y-%m-%d") | mktime) > $two_years_ago)]' node_versions.json >node_versions_recent.json

# Function to check Docker image platforms
check_platforms() {
    version=$1

    # Get platforms from manifest
    if manifest=$(docker manifest inspect "node:$version-alpine" 2>/dev/null); then
        # Extract all valid platforms (excluding unknown)
        platforms=$(echo "$manifest" | jq -r '.manifests[] | 
                select(.platform.os != "unknown" and .platform.architecture != "unknown") |
                if .platform.variant then
                  "linux/" + .platform.architecture + "/" + .platform.variant
                else
                  "linux/" + .platform.architecture
                end' | tr '\n' ',' | sed 's/,$//')

        if [ -n "$platforms" ]; then
            echo "$platforms"
            return
        fi
    fi

    # Default platforms if manifest check fails
    echo "linux/amd64,linux/arm64/v8"
}

# Process versions and add platform information (using filtered recent versions)
jq -c '[.[] | select(.version | test("v(1[8-9]|[2-9][0-9]).*"))] | group_by(.version | match("v(\\d+).*").captures[0].string | tonumber) | map(max_by(.version | match("v(\\d+\\.\\d+).*").captures[0].string | split(".") as $parts | ($parts[0] | tonumber) * 1000 + ($parts[1] | tonumber))) | map({version: .version, major: (.version | match("v(\\d+).*").captures[0].string | tonumber)})' node_versions_recent.json >versions.json

# Add platform information to each version
platforms_json="["
first=true

while IFS= read -r version_info; do
    version=$(echo "$version_info" | jq -r '.version')
    major=$(echo "$version_info" | jq -r '.major')
    version_without_v="${version#v}" # Remove 'v' prefix for Docker tag
    platforms=$(check_platforms "$version_without_v")

    if [ "$first" = true ]; then
        first=false
    else
        platforms_json="$platforms_json,"
    fi

    platforms_json="$platforms_json{\"version\":\"$version\",\"major\":$major,\"platforms\":\"$platforms\"}"
done < <(jq -c '.[]' versions.json)
platforms_json="$platforms_json]"

echo "$platforms_json" >config.json

# rm -f node_versions.json node_versions_recent.json versions.json config.json