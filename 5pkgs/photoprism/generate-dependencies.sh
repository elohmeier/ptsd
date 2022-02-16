#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nodePackages.node2nix

release=220121-2b4c8e1f

# Download package.json and package-lock.json from the release
curl https://raw.githubusercontent.com/photoprism/photoprism/${release}/frontend/package.json -o package.json
curl https://raw.githubusercontent.com/photoprism/photoprism/${release}/frontend/package-lock.json -o package-lock.json

node2nix \
  --nodejs-10 \
  --development \
  --input package.json \
  --lock package-lock.json \
  --output node-packages.nix \
  --composition node-composition.nix

rm -f package.json package-lock.json
