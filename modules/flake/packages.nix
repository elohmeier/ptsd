_: {
  perSystem = { pkgs, ... }: {
    packages = {
      inherit (pkgs)
        prom-checktlsa;
    };
  };
}
