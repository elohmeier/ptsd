{ pkgs ? import <nixpkgs> { } }:
let
  scripts = pkgs.lib.mapAttrsToList (name: value: pkgs.writeShellScriptBin name value) {
    mk-pretty = ''
      ROOT=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt $ROOT/1systems
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt $ROOT/2configs
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt $ROOT/3modules
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt $ROOT/4lib
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt $ROOT/5pkgs
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt $ROOT/lib
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt $ROOT/*.nix
      ${pkgs.jsonnet}/bin/jsonnetfmt --indent 2 --max-blank-lines 2 --sort-imports --string-style s --comment-style s -i $ROOT/.drone.jsonnet
      ${pkgs.python3Packages.black}/bin/black $ROOT/.
      ${pkgs.python3Packages.black}/bin/black $ROOT/src/*.pyw
    '';
    mk-update = ''
      ./update-home-manager.sh
      ./update-nixos-hardware.sh
      ./update-nixos-mailserver.sh
      ./update-nixpkgs.sh
      ./update-nixpkgs-unstable.sh
    '';
    mk-dummy = ''
      HOSTNAME="''${1?must provide hostname}"
      nix-build '<nixpkgs/nixos>' -A system -I nixos-config=1systems/$HOSTNAME/physical.nix -I secrets-shared=dummy-secrets -I client-secrets=dummy-secrets -I secrets=dummy-secrets -I ptsd=$(pwd)
    '';
    mk-drone-yml = "${pkgs.drone-cli}/bin/drone jsonnet --stream";
    mk-nwvpn-qr = "nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/nwvpn-qr {}'";
    mk-iso = "nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=2configs/iso.nix -I /var/src -I ptsd=$(pwd)";
    mk-eee1 = "sudo nix-build '<nixpkgs/nixos>' -A system -I nixos-config=1systems/eee1/physical.nix -I secrets=/var/src/secrets-eee1 -I /var/src -I ptsd=$(pwd) --argstr system i686-linux";
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    scripts
  ];
}
