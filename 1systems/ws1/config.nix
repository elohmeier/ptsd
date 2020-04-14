with import <ptsd/lib>;
{ config, pkgs, ... }:

{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost.nix>

    <ptsd/2configs/baseX.nix>
    <ptsd/2configs/bs53lan.nix>
    <ptsd/2configs/themes/nerdworks.nix>
    <ptsd/2configs/dovecot.nix>
    <ptsd/2configs/drone-exec-container.nix>
    <ptsd/2configs/mfc7440n.nix>
    <ptsd/2configs/syncthing.nix>

    <secrets-shared/nwsecrets.nix>
    <client-secrets/dbk/vdi.nix>
    <ptsd/2configs/home-secrets.nix>

    <ptsd/2configs/fraam-www.nix>

    <home-manager/nixos>
  ];

  home-manager = {
    users.mainUser = { pkgs, ... }:
      {
        imports = [
          ./home.nix
        ];
      };
  };

  ptsd.nwbackup = {
    cacheDir = "/persist/var/cache/borg";
    repos.nas1 = "borg-${config.networking.hostName}@192.168.178.12:.";
  };

  ptsd.secrets.files."nwbackup_id_ed25519" = {
    path = "/root/.ssh/id_ed25519";
  };

  ptsd.lego.home = "/persist/var/lib/lego";

  # default: poweroff
  #services.logind.extraConfig = "HandlePowerKey=suspend";

  # compensate X11 shutdown problems, probably caused by nvidia driver
  systemd.services.display-manager.postStop = ''
    ${pkgs.coreutils}/bin/sleep 5
  '';

  boot.tmpOnTmpfs = true;

  ptsd.vdi-container = {
    enable = true;
    extIf = "br0";
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

    bridges.br0.interfaces = [ "enp39s0" ];
    interfaces.br0.useDHCP = true;
  };

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ brlaser ];

  hardware.firmware = [ pkgs.broadcom-bt-firmware ]; # for the plugable USB stick

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

  environment.systemPackages = with pkgs; [
    samba
    home-manager
  ];

  networking.firewall.interfaces.virbr4 = {
    allowedTCPPorts = [ 445 139 ];
    allowedUDPPorts = [ 137 138 ];
  };

  ptsd.nwtraefik = {
    enable = true;
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false; # will be socket-activated
  virtualisation.libvirtd.enable = true;
}
