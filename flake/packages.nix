_: {
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        inherit (pkgs) disko hashPassword prom-checktlsa;

        inherit (pkgs.ptsd-node-packages) readability-cli;
      };
    };
}
