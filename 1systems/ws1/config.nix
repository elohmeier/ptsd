with import <ptsd/lib>;
{ config, pkgs, ... }:

{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost.nix>

    <ptsd/2configs/baseX.nix>
    <ptsd/2configs/themes/nerdworks.nix>
    <ptsd/2configs/dovecot.nix>

    <ptsd/2configs/drone-exec-container.nix>

    <secrets-shared/nwsecrets.nix>
    <client-secrets/dbk/vdi.nix>
  ];

  # default: poweroff
  #services.logind.extraConfig = "HandlePowerKey=suspend";

  # compensate X11 shutdown problems, probably caused by nvidia driver
  systemd.services.display-manager.postStop = ''
    ${pkgs.coreutils}/bin/sleep 5
  '';

  boot.tmpOnTmpfs = true;

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
    useNetworkd = true;
    useDHCP = false;

    hosts = {
      "192.168.178.10" = [ "nuc1.host.nerdworks.de" "nuc1" ]; # speed-up borg backup
    };
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

  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${config.networking.hostName}
      netbios name = ${config.networking.hostName}
      security = user
      hosts allow = 192.168.101.0/24 # host-only-virsh network
      hosts deny = 0.0.0.0/0
    '';
    shares = {
      home = {
        path = "/home/enno";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
    };
  };

  environment.systemPackages = with pkgs; [ samba ];

  networking.firewall.interfaces.virbr4 = {
    allowedTCPPorts = [ 445 139 ];
    allowedUDPPorts = [ 137 138 ];
  };
}
