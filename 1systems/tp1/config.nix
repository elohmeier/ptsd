{ config, lib, pkgs, ... }:

{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost.nix>
    <ptsd/2configs/stateless-root.nix>

    <ptsd/2configs/baseX.nix>
    <ptsd/2configs/themes/nerdworks.nix>
    <ptsd/2configs/dovecot.nix>
    <ptsd/2configs/mfc7440n.nix>
    <ptsd/2configs/syncthing.nix>

    <secrets-shared/nwsecrets.nix>
    <client-secrets/dbk/vdi.nix>
    <ptsd/2configs/home-secrets.nix>

    <home-manager/nixos>
  ];

  home-manager = {
    users.mainUser = { pkgs, ... }:
      {
        imports = [
          ./home-common.nix
        ];

        ptsd.urxvt.theme = "solarized_light";
      };
  };

  #boot.plymouth.enable = true;

  #  # https://github.com/anbox/anbox/issues/253
  #  # use:
  #  # sudo mkdir -p rootfs-overlay/system/usr/keychars
  #  # sudo cp Generic_de_DE.kcm rootfs-overlay/system/usr/keychars/anbox-keyboard.kcm
  #  virtualisation.anbox = {
  #    enable = true;
  #  };

  # reduce the noise
  ptsd.nwtelegraf.enable = lib.mkForce false;

  ptsd.vdi-container = {
    enable = true;
    extIf = "wlan0";
  };

  systemd.services.disable-bluetooth = {
    description = "Disable Bluetooth after boot to save energy";
    wantedBy = [ "multi-user.target" ];
    script = "${pkgs.rfkill}/bin/rfkill block bluetooth";
  };

  boot.tmpOnTmpfs = true;

  services.printing.enable = true;
  nixpkgs.config.allowUnfree = true;
  services.printing.drivers = with pkgs; [
    brlaser
    gutenprint
    gutenprintBin
    samsungUnifiedLinuxDriver
    splix
  ];

  #  services.avahi.enable = true;
  services.avahi.enable = false;

  services.logind.lidSwitch = "suspend-then-hibernate";

  services.udev.extraRules = ''
    # Suspend the system when battery level drops to 5% or lower
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="${pkgs.systemd}/bin/systemctl hibernate"
  '';

  networking = {
    hostName = "tp1";
    hosts = {
      #  "127.0.0.1" = [ "fritz.box" ];
      #"192.168.178.11" = [ "apu1.host.nerdworks.de" "apu1" ];
      #"192.168.178.33" = [ "prt1.host.nerdworks.de" "prt1" ];
    };

    useNetworkd = true;
    useDHCP = false;
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    wifi = {
      macAddress = "random";
      powersave = true;
    };
  };

  systemd.user.services.nm-applet = {
    description = "Network Manager applet";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    path = [ pkgs.dbus ];
    serviceConfig = {
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
      RestartSec = 3;
      Restart = "always";
    };
  };

  environment.systemPackages = with pkgs; [
    powertop
    networkmanagerapplet
    samba
    home-manager
  ];

  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${config.networking.hostName}
      netbios name = ${config.networking.hostName}
      security = user
      hosts allow = 192.168.101.0/24 # host-virsh network
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

  networking.firewall.interfaces.virbr2 = {
    allowedTCPPorts = [ 445 139 ];
    allowedUDPPorts = [ 137 138 ];
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false; # will be socket-activated
  virtualisation.libvirtd.enable = true;
}
