{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.desktop;
in
{
  imports = [
    <home-manager/nixos>
  ];

  options = {
    ptsd.desktop = {
      enableI3 = mkEnableOption "i3-desktop";
      enableSway = mkEnableOption "sway-desktop";
    };
  };

  config = mkIf cfg.enableI3 {
    services.xserver = {
      enable = true;

      layout = "de";

      libinput = {
        enable = true;
        clickMethod = "clickfinger";
        naturalScrolling = true;
      };

      # displayManager.defaultSession = "home-manager";

      # desktopManager = {
      #   session = [
      #     {
      #       name = "home-manager";
      #       start = ''
      #         ${pkgs.runtimeShell} $HOME/.xsession &
      #         waitPID=$!
      #       '';
      #     }
      #   ];
      # };
      desktopManager.xterm.enable = true;
    };

    security.pam.services.lightdm.enableGnomeKeyring = true;
    services.gnome3.gnome-keyring.enable = true;

    # required for evolution
    programs.dconf.enable = true;
    systemd.packages = [ pkgs.gnome3.evolution-data-server ];

    environment.systemPackages = with pkgs; [
      libinput
      git
      zstd # can be removed in 20.09 (default there)
      gen-secrets
      syncthing-device-id
      nwvpn-qr
      redshift
      dunst
      libnotify
      gnupg
      paperkey
      lxqt.lxqt-policykit # provides a default authentification client for policykit
      nixpkgs-fmt
      lm_sensors

      aspell
      aspellDicts.de
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science

      hunspellDicts.de-de
      hunspellDicts.en-gb-large
      hunspellDicts.en-us-large

      (writeTextFile {
        name = "drawio-mimetype";
        text = ''
          <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
            <mime-type type="application/vnd.jgraph.mxfile">
              <comment>draw.io Diagram</comment>
              <glob pattern="*.drawio" case-sensitive="true"/>
            </mime-type>
          </mime-info>
        '';
        destination = "/share/mime/packages/drawio.xml";
      })
    ];
    services.gvfs.enable = true; # allow smb:// mounts in pcmanfm

    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

    systemd.user.services.redshift = {
      description = "Screen color temperature manager";
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.redshift}/bin/redshift";
        RestartSec = 3;
        Restart = "on-failure";
      };
    };

    # yubikey
    services.udev.packages = [ pkgs.libu2f-host pkgs.yubikey-personalization ];
    services.pcscd.enable = true;

    hardware.nitrokey = {
      enable = true;
    };

    users.groups.nitrokey.members = [ config.users.users.mainUser.name ];
    users.groups.keys.members = [ config.users.users.mainUser.name ];

    fonts.fonts = with pkgs; [
      cozette
      iosevka
      nwfonts
      proggyfonts
      roboto
      roboto-slab
      source-code-pro
      win10fonts

      # required by nwi3status
      font-awesome_5
      material-design-icons
      typicons
    ];

    # for betaflight-configurator firmware flashing
    # from https://github.com/betaflight/betaflight/wiki/Installing-Betaflight#platform-specific-linux
    services.udev.extraRules = ''
      # DFU (Internal bootloader for STM32 MCUs)
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0664", GROUP="dialout"
    '';

    services.upower.enable = true;
    services.lorri.enable = true;

    home-manager =
      let
        hostConfig = config; in
      {
        users.mainUser = { config, pkgs, ... }:
          {

            xsession.enable = true;

            imports = [
              <ptsd/3modules/home>
              #<ptsd/2configs/home/git-alarm.nix> # TODO: Port to nwi3status
            ];

            services.screen-locker = {
              enable = true;
              lockCmd = lib.mkDefault "${pkgs.i3lock}/bin/i3lock";
              # lockCmd = "${pkgs.nwlock}/bin/nwlock";
              # xssLockExtraOptions = [
              #   "-n"
              #   "${pkgs.nwlock}/libexec/xsecurelock/dimmer" # nwlock package wraps custom xsecurelock
              #   "-l" # make sure not to allow machine suspend before the screen saver is active
              # ];
            };

            systemd.user.services.flameshot = {
              Unit = {
                Description = "Screenshot Tool";
              };

              Service = {
                ExecStart = "${pkgs.flameshot}/bin/flameshot";
                RestartSec = 3;
                Restart = "on-failure";
              };
            };

            ptsd.i3 = {
              enable = true;
              screenshotCommand = "exec ${pkgs.flameshot}/bin/flameshot gui";
            };

            ptsd.nwi3status =
              let
                desktopSecrets = import <secrets-shared/desktop.nix>;
              in
              {
                enable = true;
                openweathermapApiKey = desktopSecrets.openweathermapApiKey;
              };

            ptsd.pcmanfm.enable = true;

            home.packages = with pkgs;[
              xorg.xev
              xorg.xhost
              flameshot
            ];


          };
      };
  };
}