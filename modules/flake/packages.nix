_: {
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        inherit (pkgs) disko prom-checktlsa;

        inherit (pkgs.ptsd-node-packages) readability-cli;
      };
    };
}
