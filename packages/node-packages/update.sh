#!/usr/bin/env bash

node2nix \
    -i node-packages.json \
    -o node-packages.nix \
    -c composition.nix \
    --pkg-name nodejs_18
