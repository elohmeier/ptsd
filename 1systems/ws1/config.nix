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
    { output = "USB-C-0"; monitorConfig = ''Option "Rotate" "left"''; }
  ];

  services.avahi.enable = true;

  networking = {
    hostName = "ws1";
    hostId = "8c5598b5"; # required for zfs
    hosts = {
      "192.168.178.10" = [ "nuc1.host.nerdworks.de" "nuc1" ];
      "192.168.178.11" = [ "apu1.host.nerdworks.de" "apu1" ];
      "191.18.19.34" = [ "apu2.host.nerdworks.de" "apu2" ];
      "192.168.178.33" = [ "prt1.host.nerdworks.de" "prt1" ];
    };

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
