#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nixpkgs-fmt -p python3Packages.black -p python3Packages.isort -p gofumpt

set -e
ROOT=$(git rev-parse --show-toplevel)
nixpkgs-fmt $ROOT/1systems
nixpkgs-fmt $ROOT/2configs
nixpkgs-fmt $ROOT/3modules
nixpkgs-fmt $ROOT/5pkgs
nixpkgs-fmt $ROOT/*.nix      
black $ROOT/.
isort $ROOT/5pkgs
black $ROOT/src/*.pyw
isort $ROOT/src/*.pyw
gofumpt -w $ROOT/5pkgs

