_: {
  perSystem = { pkgs, ... }: {
    packages = {
      inherit (pkgs)
        chicago95
        prom-checktlsa;
    };
  };
}
