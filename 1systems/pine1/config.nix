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
    wev
    mepo
  ];
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  environment.variables.MOZ_USE_XINPUT2 = "1";

  home-manager.users.mainUser = { ... }: { imports = [ ./home.nix ]; };

  networking = {
    hostName = "pine1";
    useNetworkd = true;
    useDHCP = false;
  };

  virtualisation.waydroid.enable = true;
}
