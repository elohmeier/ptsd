# used for CI prebuilding
{ dbBackend ? "postgresql" }:

let
  unstable = import <nixpkgs-unstable> {};
in
unstable.bitwarden_rs.override { dbBackend = dbBackend; }
