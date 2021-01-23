{ pkgs ? import <nixpkgs> { } }:
let
  scripts = pkgs.lib.mapAttrsToList (name: value: pkgs.writeShellScriptBin name value) {
    mk-pretty = ''
      set -e
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
      ${pkgs.gofumpt}/bin/gofumpt -w $ROOT/5pkgs
    '';
    mk-update = ''
      ./update-gitref.sh home-manager https://github.com/rycee/home-manager release-20.09
      ./update-gitref.sh nixos-hardware https://github.com/NixOS/nixos-hardware master
      ./update-gitref.sh nixpkgs https://github.com/NixOS/nixpkgs nixos-20.09
      ./update-gitref.sh nixpkgs-unstable https://github.com/NixOS/nixpkgs nixos-unstable
    '';
    mk-conftest = ''
      HOSTNAME="''${1?must provide hostname}"
      nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=1systems/$HOSTNAME/physical.nix -I secrets-shared=dummy-secrets -I client-secrets=dummy-secrets -I secrets=dummy-secrets -I ptsd=$(pwd) ''${@:2}
    '';
    mk-dummy = ''
      HOSTNAME="''${1?must provide hostname}"
      nix-build '<nixpkgs/nixos>' -A system -I nixos-config=1systems/$HOSTNAME/physical.nix -I secrets-shared=dummy-secrets -I client-secrets=dummy-secrets -I secrets=dummy-secrets -I ptsd=$(pwd) ''${@:2}
    '';
    mk-drone-yml = "${pkgs.drone-cli}/bin/drone jsonnet --stream";
    mk-nwvpn-qr = "nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/nwvpn-qr {}'";
    mk-iso = "nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=2configs/iso.nix -I /var/src -I ptsd=$(pwd)";
    mk-eee1 = "sudo nix-build '<nixpkgs/nixos>' -A system -I nixos-config=1systems/eee1/physical.nix -I secrets=/var/src/secrets-eee1 -I /var/src -I ptsd=$(pwd) --argstr system i686-linux";
    mk-test-systems = ''
      set -e
      for sys in apu1 apu2 apu3 htz1 htz2 htz3 mb1 nas1 nuc1 rpi2 rpi4 tp1 ws1; do
        echo testing $sys...
        nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=1systems/$sys/physical.nix -I secrets-shared=dummy-secrets -I client-secrets=dummy-secrets -I secrets=dummy-secrets -I ptsd=$(pwd)
      done
    '';
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    scripts
  ];
}
