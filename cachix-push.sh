#!/usr/bin/env bash

set -e

export CACHIX_SIGNING_KEY=`pass cachix/ws1`

#echo "Building and pushing 5pkgs/vim-customized..."
#nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/vim-customized {}' | cachix push nerdworks

echo "Building and pushing 5pkgs/burrow..."
nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/burrow {}' | cachix push nerdworks

echo "Building and pushing 5pkgs/smtp-to-telegram..."
nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/smtp-to-telegram {}' | cachix push nerdworks

