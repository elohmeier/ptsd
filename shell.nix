{ pkgs ? import <nixpkgs-unstable> { } }:
let
  scripts = pkgs.lib.mapAttrsToList (name: value: pkgs.writeShellScriptBin name value) {
    mk-pretty = ''
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt 1systems
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt 2configs
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt 3modules
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt 4lib
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt 5pkgs
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt lib
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt *.nix
      ${pkgs.jsonnet}/bin/jsonnetfmt --indent 2 --max-blank-lines 2 --sort-imports --string-style s --comment-style s -i .drone.jsonnet
      ${pkgs.python3Packages.black}/bin/black .
      ${pkgs.python3Packages.black}/bin/black src/*.pyw
    '';
    mk-update = ''
      ./update-home-manager.sh
      ./update-nixos-hardware.sh
      ./update-nixos-mailserver.sh
      ./update-nixpkgs.sh
      ./update-nixpkgs-unstable.sh
    '';
    mk-drone-yml = "${pkgs.drone-cli}/bin/drone jsonnet --stream";
    mk-nwvpn-qr = "nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/nwvpn-qr {}'";
    mk-iso = "nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=2configs/iso.nix -I /var/src -I ptsd=$(pwd)";
    mk-eee1 = "sudo nix-build '<nixpkgs/nixos>' -A system -I nixos-config=1systems/eee1/physical.nix -I secrets=/var/src/secrets-eee1 -I /var/src -I ptsd=$(pwd) --argstr system i686-linux";
    mk-tp1-dummy = "nix-build '<nixpkgs/nixos>' -A system -I nixos-config=1systems/tp1/physical.nix -I secrets-shared=dummy-secrets -I client-secrets=dummy-secrets -I secrets=dummy-secrets -I ptsd=$(pwd)";
    mk-ws1-dummy = "nix-build '<nixpkgs/nixos>' -A system -I nixos-config=1systems/ws1/physical.nix -I secrets-shared=dummy-secrets -I client-secrets=dummy-secrets -I secrets=dummy-secrets -I ptsd=$(pwd)";
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    scripts
  ];
}
