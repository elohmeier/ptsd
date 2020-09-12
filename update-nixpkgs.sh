#! /usr/bin/env nix-shell
#! nix-shell -i sh -p jq -p git -p nix-prefetch-git
dir=$(dirname $0)
oldrev=$(cat $dir/nixpkgs.json | jq -r .rev | sed 's/\(.\{7\}\).*/\1/')
nix-prefetch-git \
  --url https://github.com/NixOS/nixpkgs \
  --rev refs/heads/release-20.09 \
> $dir/nixpkgs.json
newrev=$(cat $dir/nixpkgs.json | jq -r .rev | sed 's/\(.\{7\}\).*/\1/')
git commit $dir/nixpkgs.json -m "nixpkgs: $oldrev -> $newrev"

