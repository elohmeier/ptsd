{ pkgs ? import <nixpkgs> {} }:
let
  scripts = pkgs.lib.mapAttrsToList (name: value: pkgs.writeShellScriptBin name value) {
    mk-pretty = ''
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt 1systems
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt 2configs
      find 3modules -name '*.nix' ! -name 'wireguard-reresolve.nix' -exec ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt {} \;
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt 4lib
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt 5pkgs
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt lib
      ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt *.nix
      black .
      black src/*.pyw
    '';
    mk-drone-yml = "drone jsonnet --stream";
    mk-nwvpn-qr = "nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/nwvpn-qr {}'";
    mk-iso = "nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=2configs/iso.nix -I /var/src -I ptsd=$(pwd)";
    mk-eee1 = "sudo nix-build '<nixpkgs/nixos>' -A system -I nixos-config=1systems/eee1/physical.nix -I secrets=/var/src/secrets-eee1 -I /var/src --argstr system i686-linux";
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    scripts
  ];
}
