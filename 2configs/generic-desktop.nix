{ config, lib, pkgs, ... }:

with lib;
{
  imports = [
    ./users/mainuser.nix
  ];

  # TODO: remove in 23.05
  # see https://github.com/NixOS/nixpkgs/pull/202956
  systemd.services.systemd-networkd-wait-online.enable = false;

  networking = {
    wireless.iwd.enable = mkDefault true;
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      plugins = lib.mkForce [ ];
      wifi = {
        backend = "iwd";
        macAddress = "random";
        powersave = true;
      };
    };
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";

  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    layout = mkDefault "de";
  };

  console.keyMap = mkDefault "de-latin1";

  home-manager.useGlobalPkgs = true;
  home-manager.users.mainUser = { ... }: {
    home.stateVersion = "22.11";
    imports = [
      #./home/gpg.nix
      ../3modules/home
      ./home
      ./home/firefox.nix
      ./home/fish.nix
      ./home/fonts.nix
      ./home/foot.nix
      ./home/git.nix
      ./home/neovim.nix
      ./home/packages.nix
      ./home/ssh.nix
      ./home/sway.nix
      ./home/i3status.nix
    ];
  };

  programs.sway.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
  };

  hardware.bluetooth.enable = true;

  nixpkgs.config.firefox.enablePlasmaBrowserIntegration = true;

  environment.systemPackages = with pkgs;[ pavucontrol glxinfo ];
}
