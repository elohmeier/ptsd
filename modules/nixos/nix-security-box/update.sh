#!/usr/bin/env bash

set -e

tmpdir=$(mktemp -d)

trap "rm -rf $tmpdir" EXIT

wget https://github.com/fabaff/nix-security-box/archive/refs/heads/main.zip -O $tmpdir/nix-security-box.zip
unzip $tmpdir/nix-security-box.zip -d $tmpdir
cp -r $tmpdir/nix-security-box-main/*.nix .
