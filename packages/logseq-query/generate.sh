#!/usr/bin/env nix-shell
#!nix-shell -i sh -p nodePackages.node2nix
#shellcheck shell=sh

exec node2nix --development --input package.json --output node-packages.nix --composition node-composition.nix
