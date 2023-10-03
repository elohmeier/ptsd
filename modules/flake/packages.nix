_: {
  perSystem = { pkgs-unstable, ... }: {
    packages = {
      inherit (pkgs-unstable) dradis-ce prom-checktlsa;
    };
  };
}

