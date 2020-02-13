#!/usr/bin/env bash

set -e

export CACHIX_SIGNING_KEY=`pass cachix/ws1`

#echo "Building and pushing 2pkgs/vims.nix..."
#nix-build -E 'with import <nixpkgs> {}; callPackage ./2configs/vims.nix {}' | cachix push nerdworks

#echo "Building and pushing 5pkgs/burrow..."
#nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/burrow {}' | cachix push nerdworks

echo "Building and pushing 5pkgs/drone..."
nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/drone {}' | cachix push nerdworks

echo "Building and pushing 5pkgs/smtp-to-telegram..."
nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/smtp-to-telegram {}' | cachix push nerdworks

