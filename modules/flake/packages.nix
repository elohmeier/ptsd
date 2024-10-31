_: {
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        inherit (pkgs) prom-checktlsa;

        inherit (pkgs.ptsd-node-packages) readability-cli;
      };
    };
}
