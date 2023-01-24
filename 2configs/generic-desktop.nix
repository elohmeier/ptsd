{ config, lib, pkgs, ... }:

with lib;
let

in
{
  imports = [
    ./users/mainuser.nix
  ];

  systemd.network.networks = {
    #   eth = {
    #     dhcpV4Config.RouteMetric = 10;
    #     ipv6AcceptRAConfig.RouteMetric = 10;
    #     linkConfig.RequiredForOnline = "no";
    #     matchConfig.Type = "ether";
    #     networkConfig = { ConfigureWithoutCarrier = true; DHCP = "yes"; };
    #   };
    #   wlan = mkIf config.networking.wireless.iwd.enable {
    #     dhcpV4Config.RouteMetric = 20;
    #     ipv6AcceptRAConfig.RouteMetric = 20;
    #     matchConfig.Type = "wlan";
    #     networkConfig.DHCP = "yes";
    #   };
  };

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
  home-manager.users.mainUser = { config, lib, pkgs, nixosConfig, ... }: {
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

  environment.systemPackages = with pkgs;[ pavucontrol ];
}
