_: {
  perSystem = { pkgs, ... }: {
    packages = {
      inherit (pkgs) dradis-ce prom-checktlsa;
    };
  };
}

