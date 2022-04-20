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
  boot.tmpOnTmpfs = true;

  # save space
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

  environment.variables = {
    # enable touchscreen support in firefox
    MOZ_USE_XINPUT2 = "1";
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    foot.terminfo
    tmux
  ];

  # partly overridden by netboot
  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "rpi4";
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  users.users.enno = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "dialout" ];
    initialHashedPassword = "";
    openssh.authorizedKeys.keys =
      let
        sshPubKeys = import ../../2configs/users/ssh-pubkeys.nix; in
      [
        sshPubKeys.sshPub.enno_yubi41
        sshPubKeys.sshPub.enno_yubi49
      ];
    shell = pkgs.fish;
  };

  # home-manager.useGlobalPkgs = true;
  # home-manager.useUserPackages = true;
  # home-manager.users.enno = { config, nixosConfig, pkgs, ... }:
  #   {
  #     imports = [
  #       ../../2configs/home/fish.nix
  #     ];

  #     home.stateVersion = "21.05";
  #   };

  # programs.bash = {
  #   loginShellInit = ''
  #     # If running from tty1 start sway
  #     if [ "$(tty)" = "/dev/tty1" ]; then
  #       # pass sway log output to journald
  #       exec ${pkgs.systemd}/bin/systemd-cat --identifier=sway ${pkgs.sway}/bin/sway --my-next-gpu-wont-be-nvidia
  #     fi
  #   '';
  # };

  services.openssh.enable = true;
  services.getty.autologinUser = "enno";

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
