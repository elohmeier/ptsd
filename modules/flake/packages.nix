_: {
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        inherit (pkgs) aider edge-tts prom-checktlsa;
      };
    };
}
