#! /usr/bin/env nix-shell
#! nix-shell -i sh -p jq -p git -p nix-prefetch-git
dir=$(dirname $0)
oldrev=$(cat $dir/nixos-mailserver.json | jq -r .rev | sed 's/\(.\{7\}\).*/\1/')
nix-prefetch-git \
  --url https://gitlab.com/simple-nixos-mailserver/nixos-mailserver.git \
  --rev refs/heads/v2.3.0 \
> $dir/nixos-mailserver.json
newrev=$(cat $dir/nixos-mailserver.json | jq -r .rev | sed 's/\(.\{7\}\).*/\1/')
git commit $dir/nixos-mailserver.json -m "nixos-mailserver: $oldrev -> $newrev"
