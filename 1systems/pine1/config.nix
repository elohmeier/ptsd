{ config, lib, pkgs, ... }:

{
  imports = [
    ../..
    ../../2configs
    ../../2configs/nwhost.nix

    ../../2configs/users/enno.nix
  ];

  ptsd.nwbackup.enable = false;
  ptsd.nwacme.enable = false;
  ptsd.tor-ssh.enable = false;

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };
  services.getty.autologinUser = "enno";
  environment.systemPackages = with pkgs; [
    htop
    wvkbd
    bemenu
    foot
    foot.terminfo
    # element-desktop # todo: rm gcc dep
    wev
    mepo
  ];
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  programs.bash.loginShellInit = ''
    if [ "$(tty)" = "/dev/tty1" ]; then
      exec ${pkgs.systemd}/bin/systemd-cat --identifier=sway ${pkgs.sway}/bin/sway
    fi
  '';
  environment.variables.MOZ_USE_XINPUT2 = "1";

  home-manager.users.mainUser = { ... }: { imports = [ ./home.nix ]; };


  networking = {
    hostName = "pine1";
    useNetworkd = true;
    useDHCP = false;
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi = {
        backend = "iwd";
        macAddress = "random";
        powersave = true;
      };
    };

    wireless.iwd.enable = true;

    # missing kernel module?
    firewall.enable = false;
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  services.udev.packages = [ pkgs.sxmo-utils ];

  services.logind.extraConfig = "HandlePowerKey=ignore";




  systemd.services.sxmo-setpermissions = {
    description = "Set device-specific permissions for sxmo";
    wantedBy = [
      "multi-user.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.sxmo-utils}/bin/sxmo_setpermissions.sh";
    };
  };

  virtualisation.waydroid.enable = true;
}
