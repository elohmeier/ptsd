#! /usr/bin/env nix-shell
#! nix-shell -i sh -p jq -p git -p nix-prefetch-git
dir=$(dirname $0)
oldrev=$(cat $dir/home-manager.json | jq -r .rev | sed 's/\(.\{7\}\).*/\1/')
nix-prefetch-git \
  --url https://github.com/rycee/home-manager \
  --rev refs/heads/release-19.09 \
> $dir/home-manager.json
newrev=$(cat $dir/home-manager.json | jq -r .rev | sed 's/\(.\{7\}\).*/\1/')
git commit $dir/home-manager.json -m "home-manager: $oldrev -> $newrev"

