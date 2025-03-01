{ pkgs, nodejs }:

let
  inherit (pkgs) stdenv lib;
in

_final: prev: {
  inherit nodejs;

  readability-cli = prev.readability-cli.override {
    nativeBuildInputs = [
      pkgs.pkg-config
      # pkgs.node-pre-gyp
    ];
    # These dependencies are required by
    # https://github.com/Automattic/node-canvas.
    buildInputs =
      with pkgs;
      [
        giflib
        pixman
        cairo
        pango
      ]
      ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.CoreText ];
  };

}
