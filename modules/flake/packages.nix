_: {
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        inherit (pkgs) edge-tts prom-checktlsa zathura-darwin;
      };
    };
}
