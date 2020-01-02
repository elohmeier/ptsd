{ config, lib, pkgs, ... }:

{
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = nuc1
      netbios name = nuc1
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

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 445 139 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];
}
