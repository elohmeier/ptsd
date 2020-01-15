{ config, lib, pkgs, ... }:

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

  #  # https://github.com/anbox/anbox/issues/253
  #  # use:
  #  # sudo mkdir -p rootfs-overlay/system/usr/keychars
  #  # sudo cp Generic_de_DE.kcm rootfs-overlay/system/usr/keychars/anbox-keyboard.kcm
  #  virtualisation.anbox = {
  #    enable = true;
  #  };


  #nix.nixPath = [
  #  "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
  #  "nixos-config=/etc/nixos/configuration.nix"
  #  "/nix/var/nix/profiles/per-user/root/channels"
  #  "ptsd=/etc/nixos/ptsd"
  #];

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

  ptsd.nwvpn.ifname = "nwvpn";

  #  services.dlrgvpn = {
  #    # DNS resolution to Uwe will often fail after boot, so only enable when needed
  #    enable = false;
  #    vpnIP = "191.18.21.30";
  #    vpnKey = "";
  #  };

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

  services.syncthing = {
    enable = true;
    user = "enno";
    group = "users";
    configDir = "/home/enno/.config/syncthing";
    dataDir = "/home/enno/";
  };

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

    useNetworkd = false;
    useDHCP = false;
  };

  networking.networkmanager = {
    enable = true;
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
    (wineStaging.override { wineBuild = "wine32"; })
    powertop
    networkmanagerapplet
  ];
}
