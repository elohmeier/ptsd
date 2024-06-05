_: {
  perSystem = { pkgs, ... }: {
    packages = {
      inherit (pkgs)
        chicago95
        dradis-ce
        prom-checktlsa;
    };
  };
}
