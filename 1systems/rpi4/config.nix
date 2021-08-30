{ config
, lib
, pkgs
, nixpkgs-master
, ...
}:
{
  imports = [
    ../..
    ../../2configs/fish.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" ];

  hardware.raspberry-pi."4".fkms-3d.enable = true;

  # save space
  hardware.enableRedistributableFirmware = lib.mkForce false;
  hardware.firmware = [ pkgs.raspberrypiWirelessFirmware ];
  hardware.wirelessRegulatoryDatabase = true;
  services.udisks2.enable = false;
  #environment.noXlibs = true;
  documentation.enable = false;
  documentation.nixos.enable = false;
  environment.defaultPackages = [ ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  nix.nixPath = [
    "nixpkgs=${nixpkgs-master}"
  ];

  console.keyMap = "de-latin1";

  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      foot
      dmenu
    ];
  };

  environment.variables = {
    # enable touchscreen support in firefox
    MOZ_USE_XINPUT2 = "1";
  };

  # initrd shouldn't get too large...
  # environment.systemPackages = with pkgs; [
  #   firefox
  #   glxinfo
  # ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "rpi4";
    interfaces.eth0.useDHCP = true;
  };

  users.users.enno = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialHashedPassword = "";
    openssh.authorizedKeys.keys =
      let
        sshPubKeys = import ../../2configs/users/ssh-pubkeys.nix; in
      [
        sshPubKeys.sshPub.enno_yubi41
        sshPubKeys.sshPub.enno_yubi49
      ];
    #          shell = pkgs.fish;
  };

  programs.bash = {
    loginShellInit = ''
      # If running from tty1 start sway
      if [ "$(tty)" = "/dev/tty1" ]; then
        # pass sway log output to journald
        exec ${pkgs.systemd}/bin/systemd-cat --identifier=sway ${pkgs.sway}/bin/sway --my-next-gpu-wont-be-nvidia
      fi
    '';
  };

  home-manager.users.enno = { config, nixosConfig, pkgs, ... }:
    {
      imports = [
        ../../2configs/home/fish.nix
      ];

      wayland.windowManager.sway = {
        enable = true;
        config = {
          bars = [{
            command = "${pkgs.waybar}/bin/waybar";
          }];

          input = {
            "*" = {
              xkb_layout = "de";
            };

            raspberrypi-ts = {
              map_to_output = "DSI-1";
            };
          };
          modifier = "Mod4";
          terminal = "${pkgs.foot}/bin/foot";
        };
      };

      programs.waybar = {
        enable = true;
      };

      home.stateVersion = "21.05";
    };

  services.openssh.enable = true;
  services.getty.autologinUser = "enno";
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
