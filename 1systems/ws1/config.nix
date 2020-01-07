with import <ptsd/lib>;
{ config, pkgs, ... }:

{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost.nix>

    <ptsd/2configs/baseX.nix>
    <ptsd/2configs/dovecot.nix>

    <secrets-shared/nwsecrets.nix>
    <client-secrets/dbk/vdi.nix>
  ];

  ptsd.vdi-container = {
    enable = true;
    extIf = "virbr0";
  };

  services.xserver.xrandrHeads = [
    { output = "DP-0"; primary = true; }
    {
      output = "USB-C-0";
      # monitorConfig = ''Option "Rotate" "left"'';
    }
  ];

  services.avahi.enable = true;

  networking = {
    hostName = "ws1";
    hostId = "8c5598b5"; # required for zfs
    useNetworkd = true;
    useDHCP = false;
  };

  systemd.network = {
    enable = true;
    networks = {
      "99-main" = {
        matchConfig = {
          MACAddress = "00:d8:61:77:1c:77";
        };
        networkConfig = {
          Bridge = "virbr0";
        };
      };
      "virbr0" = {
        DHCP = "yes";
        #dhcpConfig = { UseDNS = false; };
        #dns = ["192.168.178.10"];
        matchConfig = {
          Name = "virbr0";
        };
      };
    };
    netdevs = {
      "virbr0" = {
        netdevConfig = {
          Name = "virbr0";
          Kind = "bridge";
        };
      };
    };
  };

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ brlaser ];

  services.syncthing = {
    enable = true;
    user = "enno";
    group = "users";
    configDir = "/home/enno/.config/syncthing";
    dataDir = "/home/enno/";
  };
}
