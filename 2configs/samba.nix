{ config, lib, pkgs, ... }:

{
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${config.networking.hostName}
      netbios name = ${config.networking.hostName}
      security = user
      hosts allow = 192.168.178.0/24
      hosts deny = 0.0.0.0/0

      # allow broken auth for sonos client
      ntlm auth = yes
    '';
    shares = {
      media = {
        path = "/mnt/int/media";
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
}
