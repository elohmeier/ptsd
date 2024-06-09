_: {
  perSystem = { pkgs, ... }: {
    packages = {
      inherit (pkgs)
        aider
        prom-checktlsa;
    };
  };
}
