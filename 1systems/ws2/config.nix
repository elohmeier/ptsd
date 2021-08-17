{ config, lib, pkgs, ... }:
with lib;

{
  imports = [
    ../../.
    ../../2configs
    ../../2configs/desktop.nix
    ../../2configs/nwhost.nix
    ../../2configs/stateless-root.nix
    ../../2configs/themes/dark.nix

    ../../2configs/prometheus/node.nix

    #../../2configs/octoprint-klipper-ender3.nix
    ../../2configs/printers/hl5380dn.nix

    #../../2configs/nvidia-headless.nix
    ../../2configs/profiles/workstation
  ];

  # ptsd.fraamdb = {
  #   enable = true;
  #   devSrc = "/home/enno/repos/fraamdb";
  #   debug = true;
  #   domain = "127.0.0.1";
  #   httpsOnly = false;
  # };

  home-manager = {
    users.mainUser = { ... }:
      {
        imports = [
          ./home.nix
        ];
      };
  };

  networking = {
    hostName = "ws2";
    useNetworkd = true;
    useDHCP = false;
    interfaces.wlan0.useDHCP = true;

    wireless.iwd.enable = true;

    firewall.interfaces = {
      wlan0 = {
        # samba/cups ports
        allowedTCPPorts = [ 631 445 139 ];
        allowedUDPPorts = [ 631 137 138 ];
      };
    };

    nat.externalInterface = "wlan0";

    #  hosts = {
    #    "10.129.120.124" = [ "forum.bart.htb" "bart.htb" "monitor.bart.htb" "internal-01.bart.htb" ];
    #  };
  };

  ptsd.secrets.files."fraam.psk" = {
    path = "/var/lib/iwd/fraam.psk";
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  ptsd.desktop = {
    enable = true;
    rclone.enable = true;
  };

  ptsd.nwacme.hostCert.enable = false;

  ptsd.nwbackup = {
    enable = true;
    paths = [ "/home" ];
  };

  services.samba.shares = {
      scans = {
        path = "/home/enno/repos/nobbofin/000_INBOX/scans";
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
        "force group" = "users";
        "force user" = "enno";
      };
      public = {
        path = "/home/public";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
      };
    };

  users.users.scanner = { isSystemUser = true; };

  ptsd.nwsyncthing = {
    enable = true;

    folders = {
      "/home/enno/Pocket" = {
        id = "hmekh-kgprn";
        devices = [ "nas1" "nuc1" "tp1" "tp1-win10" "ws1" "ws1-win10" ];
      };
      "/home/enno/Templates" = {
        id = "gnwqu-yt7qc";
        devices = [ "nas1" "tp1" "ws1" ];
      };
      "/home/enno/Scans" = {
        id = "ezjwj-xgnhe";
        devices = [ "nas1" "tp1" "ws1" ];
      };
    };
  };

  hardware.printers = {
    ensureDefaultPrinter = "HL5380DN";
  };
}
