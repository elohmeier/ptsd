{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.samba-sonos;
in
{
  options = {
    ptsd.samba-sonos = {
      enable = mkEnableOption "samba-sonos";
      mediaPath = mkOption {
        type = types.str;
      };
      mediaUsername = mkOption {
        type = types.str;
        default = "media";
      };
      hostsAllow = mkOption {
        type = types.str;
        default = "192.168.178.0/24";
      };
    };
  };

  config = mkIf cfg.enable {

    # remember to set the password manually
    # using `smbpasswd -a <username>`
    users.users.${cfg.mediaUsername} = {
      name = cfg.mediaUsername;
      isSystemUser = true;
      home = cfg.mediaPath;
      createHome = false;
      useDefaultShell = true;
      description = "Media User";
    };

    services.samba = {
      enable = true;
      securityType = "user";
      extraConfig = ''
        workgroup = WORKGROUP
        server string = ${config.networking.hostName}
        netbios name = ${config.networking.hostName}
        security = user
        hosts allow = ${cfg.hostsAllow}
        hosts deny = 0.0.0.0/0

        # allow broken auth for sonos client
        ntlm auth = yes
      '';

      shares = {
        media = {
          path = cfg.mediaPath;
          browseable = "yes";
          "read only" = "yes";
          "guest ok" = "no";
        };
      };
    };

    environment.systemPackages = [ pkgs.samba ];

    networking.firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 445 139 ];
      allowedUDPPorts = [ 137 138 ];
    };

  };

}
