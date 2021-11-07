{ config, lib, pkgs, ... }:

let
  pkg = pkgs.ptsd-python3.pkgs.icloudpd;
  reauth = pkgs.writeShellScriptBin "icloudpd-reauth" ''
    set -e
    source ${config.ptsd.secrets.files."icloud.env".path}
    ${pkg}/bin/icloudpd \
      --directory /tank/enc/rawphotos/photos/icloudpd \
      --username "$ICLOUD_USER" \
      --password "$ICLOUD_PASS" \
      --cookie-directory /var/lib/icloudpd \
      --list-albums
  '';
in
{
  systemd.services.icloudpd = {
    description = "Download iCloud photos and videos";
    script = ''
      ${pkg}/bin/icloudpd \
        --directory /tank/enc/rawphotos/photos/icloudpd \
        --username "$ICLOUD_USER" \
        --password "$ICLOUD_PASS" \
        --cookie-directory "$STATE_DIRECTORY"
    '';
    wants = [ "network.target" "network-online.target" ];
    after = [ "network.target" "network-online.target" ];

    serviceConfig = {
      EnvironmentFile = config.ptsd.secrets.files."icloud.env".path;
      Restart = "no";
      Type = "oneshot";

      User = "nextcloud";
      Group = "nginx";
      StateDirectory = "icloudpd";
    };

    startAt = "*-*-* 05:30:00";
  };

  environment.systemPackages = [ pkg reauth ];

  ptsd.secrets.files."icloud.env" = {
    dependants = [ "icloudpd.service" ];
  };
}
