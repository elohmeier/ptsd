{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.fraam-gitlab;
in
{
  options = {
    ptsd.fraam-gitlab = {
      enable = mkEnableOption "fraam-gitlab";
      extIf = mkOption {
        type = types.str;
        description = "external network interface container traffic will be NATed over";
      };
      containerAddress = mkOption {
        type = types.str;
        default = "192.168.100.16";
        description = "IP address of the container in the private host/container-network";
      };
      hostAddress = mkOption {
        type = types.str;
        default = "192.168.100.10";
        description = "IP address of the host in the private host/container-network";
      };
      domain = mkOption {
        type = types.str;
      };
      entryPoints = mkOption {
        type = with types; listOf str;
        default = [ "loopback6-http" "loopback6-https" ];
      };
    };
  };

  config = mkIf cfg.enable {


    networking = {
      nat = {
        enable = true;
        internalInterfaces = [ "ve-+" ];
        externalInterface = cfg.extIf;
      };
    };


    containers.gitlab = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.containerAddress;
      bindMounts = { };
      ephemeral = true;

      config =
        { config, pkgs, ... }:
        {
          imports = [
            <ptsd>
            <ptsd/2configs>
          ];

          boot.isContainer = true;

          networking = {
            useHostResolvConf = false;
            nameservers = [ "8.8.8.8" "8.8.4.4" ];
            useNetworkd = true;
            firewall.allowedTCPPorts = [ 80 ];
          };

          time.timeZone = "Europe/Berlin";

          i18n = {
            defaultLocale = "de_DE.UTF-8";
            supportedLocales = [ "de_DE.UTF-8/UTF-8" ];
          };

          # create user using https://docs.gitlab.com/12.10/ee/security/reset_root_password.html
          # and https://nixos.org/manual/nixos/stable/index.html#module-services-gitlab
          # use user.activate! and user.admin = true, then user.save!

          services.gitlab =
            {
              enable = true;
              initialRootPasswordFile = pkgs.writeText "gitlab-initialRootPasswordFile" "todo";
              secrets = {
                secretFile = pkgs.writeText "gitlab-secretFile" "todo";
                dbFile = pkgs.writeText "gitlab-dbFile" "todo";
                otpFile = pkgs.writeText "gitlab-otpFile" "todo";
                jwsFile = pkgs.writeText "gitlab-jwsFile" "todo";
              };
            };

          # waits for https://github.com/traefik/traefik/issues/4881
          services.nginx = {
            enable = true;
            recommendedGzipSettings = true;
            recommendedOptimisation = true;
            recommendedProxySettings = true;
            virtualHosts."${cfg.domain}" = {
              locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
            };
          };
        };
    };

    # HACK: gitaly in nixos-20.09 requires git 2.29, which isn't yet in 20.09.
    # Remove when https://github.com/NixOS/nixpkgs/pull/104896 is merged.
    nixpkgs.overlays = [
      (self: super: {
        git = super.git.overrideAttrs (old: rec {
          version = "2.29.2";
          src = self.fetchurl {
            url = "https://www.kernel.org/pub/software/scm/git/git-${version}.tar.xz";
            sha256 = "1h87yv117ypnc0yi86941089c14n91gixk8b6shj2y35prp47z7j";
          };
        });
      })
    ];

    ptsd.nwtraefik = {
      services = [
        {
          url = "http://${cfg.containerAddress}:80";
          name = "gitlab";
          entryPoints = cfg.entryPoints;
          rule = "Host(`${cfg.domain}`)";
        }
      ];
    };
  };
}
