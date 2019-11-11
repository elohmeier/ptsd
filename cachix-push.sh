#!/usr/bin/env bash

set -e

export CACHIX_SIGNING_KEY=`pass cachix/ws1`

echo "Building and pushing 5pkgs/vim-customized..."
nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/vim-customized {}' | cachix push nerdworks

