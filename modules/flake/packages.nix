{ lib, ... }:
{
  perSystem = { pkgs, ... }: {
    packages = rec {
      inherit (pkgs) dradis-ce;
    };
  };
}

