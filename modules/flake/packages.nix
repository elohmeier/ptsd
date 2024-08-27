_: {
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        inherit (pkgs) edge-tts prom-checktlsa zathura-darwin;

        inherit (pkgs.ptsd-node-packages) readability-cli;
      };
    };
}
