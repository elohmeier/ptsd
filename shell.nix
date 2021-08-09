{ pkgs ? import <nixpkgs> { } }:
let
  scripts = pkgs.lib.mapAttrsToList (name: value: pkgs.writeShellScriptBin name value) {
    mk-conftest = ''
      HOSTNAME="''${1?must provide hostname}"
      nix-instantiate '<nixpkgs/nixos>' -A system -I nixos-config=1systems/$HOSTNAME/physical.nix -I secrets-shared=dummy-secrets -I client-secrets=dummy-secrets -I secrets=dummy-secrets -I ptsd=$(pwd) ''${@:2}
    '';
    mk-dummy = ''
      HOSTNAME="''${1?must provide hostname}"
      nix-build '<nixpkgs/nixos>' -A system -I nixos-config=1systems/$HOSTNAME/physical.nix -I secrets-shared=dummy-secrets -I client-secrets=dummy-secrets -I secrets=dummy-secrets -I ptsd=$(pwd) ''${@:2}
    '';
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
    #packer

    # klipper deps    
    #(python2.withPackages (p: with p; [ cffi pyserial greenlet jinja2 ]))
  ];
  #KLIPPER = pkgs.klipper;
}
