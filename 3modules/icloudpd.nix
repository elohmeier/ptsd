{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.icloudpd;
  pkg = pkgs.ptsd-python3.pkgs.icloudpd;

  generateService = jobname: jobcfg: nameValuePair "icloudpd-${name}" {
    description = "Download iCloud photos and videos (${name})";

    # TODO: prevent execution if cookie token outdated because of nasty iOS 2FA prompts
    script = ''
      ${pkg}/bin/icloudpd \
        --directory "${jobcfg.directory}" \
        --username "$ICLOUD_USER" \
        --password "$ICLOUD_PASS" \
        --cookie-directory "$STATE_DIRECTORY"
    '';
    wants = [ "network.target" "network-online.target" ];
    after = [ "network.target" "network-online.target" ];

    serviceConfig = {
      EnvironmentFile = jobcfg.envFile;
      Restart = "no";
      Type = "oneshot";

      User = jobcfg.user;
      Group = jobcfg.group;
      StateDirectory = "icloudpd-${name}";
    };

    startAt = "*-*-* 05:30:00";
  };

  generateReauthScript = jobname: jobcfg: pkgs.writeShellScriptBin "icloudpd-${name}-reauth" ''
    set -e
    source ${jobcfg.envFile}
    ${pkg}/bin/icloudpd \
      --directory "${jobcfg.directory}" \
      --username "$ICLOUD_USER" \
      --password "$ICLOUD_PASS" \
      --cookie-directory "/var/lib/icloudpd-${name}" \
      --list-albums
  '';
in
{
  options.ptsd.icloudpd = {
    jobs = mkOption {
      type = types.attrsOf
        (
          types.submodule (
            { config, ... }: {
              options = {
                name = mkOption {
                  type = types.strMatching "[A-Za-z0-9]+";
                  default =
                    config._module.args.name;
                };
                directory = mkOption {
                  type = types.path;
                  description = "directory to download the photos and videos to";
                };
                envFile = mkOption {
                  type = types.path;
                  description = "environment file specifying the ICLOUD_USER and ICLOUD_PASS variables";
                };
                user = mkOption { type = types.str; };
                group = mkOption { type = types.str; };
              };
            };
        );
      default = { };
    };
  };

  systemd.services = mapAttrs' generateService cfg.jobs;
  environment.systemPackages = mapAttrsToList generateReauthScript cfg.jobs;
}
