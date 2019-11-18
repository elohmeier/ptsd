{ pkgs ? import <nixpkgs> {}, ... }:

{
  burrow = pkgs.callPackage ./burrow {};
}
