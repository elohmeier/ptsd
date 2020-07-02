{ name
, desktop ? false
, unstable ? false
, mailserver ? false
, secrets ? true
, client-secrets ? false
, starget ? "root@${name}.host.nerdworks.de"
}:
let
  #krops = (import <nixpkgs> {}).fetchgit {
  #  url = https://cgit.krebsco.de/krops/;
  #  rev = "v1.18.1";
  #  sha256 = "061ngm42xfr9grmchwzx6v3zmraych23xc1miimdsyd65y9hg4c5";
  #};

  krops = ./submodules/krops;

  lib = import "${krops}/lib";
  pkgs = import "${krops}/pkgs" {};

  source = lib.evalSource [
    {
      nixpkgs.git = {
        clean.exclude = [ "/.version-suffix" ];
        ref = (lib.importJSON ./nixpkgs.json).rev;
        url = https://github.com/NixOS/nixpkgs;
        shallow = true;
      };

      nixos-hardware.git = {
        clean.exclude = [ "/.version-suffix" ];
        ref = (lib.importJSON ./nixos-hardware.json).rev;
        url = https://github.com/NixOS/nixos-hardware;
        shallow = true;
      };

      ptsd.file = toString ./.;

      nixos-config.symlink = "ptsd/1systems/${name}/physical.nix";
    }

    (
      lib.optionalAttrs secrets {
        secrets.pass = {
          #dir = "${lib.getEnv "HOME"}/.password-store";
          dir = "${lib.getEnv "PASSWORD_STORE_DIR"}";
          name = "hosts/${name}";
        };

        secrets-shared.pass = {
          dir = "${lib.getEnv "PASSWORD_STORE_DIR"}";
          name = "hosts-shared";
        };
      }
    )

    (
      lib.optionalAttrs (unstable || desktop) {
        nixpkgs-unstable.git = {
          clean.exclude = [ "/.version-suffix" ];
          ref = (lib.importJSON ./nixpkgs-unstable.json).rev;
          url = https://github.com/NixOS/nixpkgs;
          shallow = true;
        };
      }
    )

    (
      lib.optionalAttrs (mailserver) {
        nixos-mailserver.git = {
          clean.exclude = [ "/.version-suffix" ];
          ref = (lib.importJSON ./nixos-mailserver.json).rev;
          url = https://gitlab.com/simple-nixos-mailserver/nixos-mailserver.git;
          shallow = true;
        };
      }
    )

    (
      lib.optionalAttrs (client-secrets || desktop) {
        client-secrets.pass = {
          dir = "${lib.getEnv "PASSWORD_STORE_DIR"}";
          name = "clients";
        };
      }
    )

    (
      lib.optionalAttrs desktop {
        ci.git = {
          ref = "45fb55f3615a7613c4413c99320816e339735c70";
          url = "git@git.nerdworks.de:nerdworks/ci.git";
          shallow = true;
        };

        home-manager.git = {
          clean.exclude = [ "/.version-suffix" ];
          ref = (lib.importJSON ./home-manager.json).rev;
          url = https://github.com/rycee/home-manager;
          shallow = true;
        };

        secrets-eee1.pass = {
          dir = "${lib.getEnv "PASSWORD_STORE_DIR"}";
          name = "hosts/eee1";
        };
      }
    )
  ];

  #target = lib.mkTarget "root@${name}.host.nerdworks.de";
  target = lib.mkTarget starget;
in
rec {
  # usage: $(nix-build --no-out-link krops.nix --argstr name HOSTNAME -A deploy)
  # usage: $(nix-build --no-out-link krops.nix --argstr name HOSTNAME --arg desktop true -A deploy)
  deploy =
    pkgs.krops.writeDeploy "deploy" {
      source = source;
      target = target;
    };

  # usage: $(nix-build --no-out-link krops.nix --argstr name HOSTNAME -A deploy_ptsd)
  # usage: $(nix-build --no-out-link krops.nix --argstr name HOSTNAME --arg desktop true -A deploy_ptsd)
  deploy_ptsd =
    pkgs.krops.writeDeploy "deploy_ptsd" {
      source = lib.evalSource [
        { ptsd.file = toString ./.; }
        (
          lib.optionalAttrs secrets {
            secrets.pass = {
              #dir = "${lib.getEnv "HOME"}/.password-store";
              dir = "${lib.getEnv "PASSWORD_STORE_DIR"}";
              name = "hosts/${name}";
            };

            secrets-shared.pass = {
              dir = "${lib.getEnv "PASSWORD_STORE_DIR"}";
              name = "hosts-shared";
            };
          }
        )
        (
          lib.optionalAttrs (secrets && desktop) {
            client-secrets.pass = {
              dir = "${lib.getEnv "PASSWORD_STORE_DIR"}";
              name = "clients";
            };
          }
        )
      ];
      target = target;
      fast = true;
    };

  # usage: $(nix-build --no-out-link krops.nix --argstr name HOSTNAME -A populate)
  # usage: $(nix-build --no-out-link krops.nix --argstr name HOSTNAME --arg desktop true -A populate)
  # usage: $(nix-build --no-out-link krops.nix --argstr name HOSTNAME --argstr starget "root@IP/mnt/var/src" --arg desktop true -A populate)
  populate = pkgs.populate {
    source = source;
    target = target;
  };

  populate_sudo = pkgs.populate {
    source = source;
    target = target // {
      sudo = true;
    };
  };

  populate_shallow = pkgs.populate {
    source = lib.evalSource [
      {
        nixpkgs-shallow.git = {
          clean.exclude = [ "/.version-suffix" ];
          ref = (lib.importJSON ./nixpkgs.json).rev;
          url = https://github.com/NixOS/nixpkgs;
          shallow = true;
        };
      }
    ];
    target = target;
  };

  # build without switching to the new config (to test the build)
  # usage: $(nix-build --no-out-link krops.nix --argstr name HOSTNAME -A build_remote)
  build_remote =
    pkgs.writers.writeDash "build_remote" ''
      set -efu
      ${populate}
      ${pkgs.krops.rebuild [ "dry-build" ] target}
      ${pkgs.krops.build target}
    '';

  # build without switching to the new config (will be activated after next reboot)
  # usage: $(nix-build --no-out-link krops.nix --argstr name HOSTNAME -A deploy_boot)
  deploy_boot =
    pkgs.writers.writeDash "deploy_boot" ''
      set -efu
      ${populate}
      ${pkgs.krops.rebuild [ "boot" ] target}
      ${pkgs.krops.build target}
    '';
}
