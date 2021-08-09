{ config, lib, pkgs, ... }:
{
  imports = [
    ../../2configs/home
    ../../2configs/home/extraTools.nix
    ../../2configs/home/gpg.nix
  ];

  home.stateVersion = "20.09";
  programs.fish = {
    enable = true;
    shellAliases = (import ../../2configs/aliases.nix).aliases;
    shellAbbrs = (import ../../2configs/aliases.nix).abbreviations;
  };

  wayland.windowManager.sway = {
    extraConfig = ''
      output "Goldstar Company Ltd LG UltraFine 701NTAB7S144" pos 0 0 mode 4096x2304@59.999Hz scale 2
      output "Dell Inc. DELL P2415Q D8VXF96K09HB" pos 0 1152 mode 3840x2160@59.997Hz scale 2
      output "Dell Inc. DELL P2415Q D8VXF64G0LGL" pos 1920 1152 mode 3840x2160@59.997Hz scale 2
    '';

    # extraConfig = ''
    #  output "Goldstar Company Ltd LG UltraFine 701NTAB7S144" pos 0 0 mode 4096x2304@59.999Hz scale 2.191406
    #  output "Dell Inc. DELL P2415Q D8VXF96K09HB" pos 0 1052 mode 3840x2160@59.997Hz scale 1.859375
    #  output "Dell Inc. DELL P2415Q D8VXF64G0LGL" pos 2064 1052 mode 3840x2160@59.997Hz scale 1.859375
    #'';
  };

  home = {
    packages = with pkgs; [
      lguf-brightness
    ];
  };

  ptsd.pcmanfm.enableRdpAssistant = true;

  xsession.initExtra = ''
    # disable screensaver
    ${pkgs.xorg.xset}/bin/xset s off -dpms
  '';
}
