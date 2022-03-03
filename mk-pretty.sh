#!/usr/bin/env sh

ROOT=$(git rev-parse --show-toplevel)
nixpkgs-fmt $ROOT
black $ROOT

