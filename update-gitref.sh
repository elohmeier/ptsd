#! /usr/bin/env nix-shell
#! nix-shell -i bash -p jq -p git
NAME="${1?must provide name}"
URL="${2?must provide url}"
REF="${3?must provide ref}"
set -e
dir=$(dirname "$0")
oldrev=$(jq -r .rev < "$dir/${NAME}.json" | sed 's/\(.\{7\}\).*/\1/')
newrev=$(git ls-remote "$URL" "$REF" | cut -f1)
jq -n --arg rev "$newrev" '{"rev":$rev}' > "$dir/${NAME}.json"
newrev=$(sed 's/\(.\{7\}\).*/\1/' <<< "$newrev")
git commit "$dir/${NAME}.json" -m "$NAME: $oldrev -> $newrev"
