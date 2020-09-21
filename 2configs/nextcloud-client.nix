{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nextcloud-client
  ];

  systemd.user.services.nextcloud-client = {
    description = "Nextcloud Desktop Client";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.nextcloud-client}/bin/nextcloud";
      RestartSec = 3;
      Restart = "always";
    };
  };
}
