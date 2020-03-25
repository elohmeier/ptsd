#! /usr/bin/env nix-shell
#! nix-shell -i sh -p jq -p git -p nix-prefetch-git
dir=$(dirname $0)
oldrev=$(cat $dir/nixpkgs.json | jq -r .rev | sed 's/\(.\{7\}\).*/\1/')
nix-prefetch-git \
  --url https://github.com/NixOS/nixos-hardware \
  --rev refs/heads/master \
> $dir/nixos-hardware.json
newrev=$(cat $dir/nixos-hardware.json | jq -r .rev | sed 's/\(.\{7\}\).*/\1/')
git commit $dir/nixos-hardware.json -m "nixos-hardware: $oldrev -> $newrev"
