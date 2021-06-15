#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

# Download package.json and package-lock.json from the 210523-b1856b9d release
curl https://raw.githubusercontent.com/photoprism/photoprism/b1856b9d45502ba1a35e1d2ae6ca12fd17223895/frontend/package.json -o package.json
curl https://raw.githubusercontent.com/photoprism/photoprism/b1856b9d45502ba1a35e1d2ae6ca12fd17223895/frontend/package-lock.json -o package-lock.json

node2nix \
  --nodejs-10 \
  --development \
  --input package.json \
  --lock package-lock.json \
  --output node-packages.nix \
  --composition node-composition.nix

rm -f package.json package-lock.json
