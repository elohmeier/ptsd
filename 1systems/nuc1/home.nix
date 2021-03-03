{ config, lib, pkgs, ... }:
let
  baresipSecrets = import <secrets/baresip.nix>;
  homeSecrets = import <client-secrets/home-secrets.nix>;
in
{
  imports = [
    <ptsd/2configs/home>
    <ptsd/2configs/home/extraTools.nix>
    <ptsd/2configs/home/firefox.nix>
    <ptsd/2configs/home/gpg.nix>
  ];

  # dual iiyama
  #wayland.windowManager.sway.extraConfig = ''
  #  output HDMI-A-1 pos 0 0 mode 2560x1440@59.951000Hz scale 1
  #  output HDMI-A-2 pos 2560 0 mode 1920x1200@59.950001Hz scale 1
  #'';

  wayland.windowManager.sway.extraConfig = ''
    output HDMI-A-1 pos 0 0 mode 1920x1080@59.933998Hz scale 1
    output HDMI-A-2 pos 1920 120 mode 1920x1200@59.950001Hz scale 1
  '';

  ptsd.baresip = {
    enable = true;
    username = "nuc1baresip";
    registrar = "192.168.178.1";
    password = baresipSecrets.password;
    netInterface = "nwvpn";
    audioPlayer = "alsa_output.usb-Plantronics_Plantronics_Voyager_Base_CD_f169d9bb77a148e4b7e910d4a64d4e15-00.analog-stereo";
    #audioSource = "alsa_input.usb-Plantronics_Plantronics_Voyager_Base_CD_f169d9bb77a148e4b7e910d4a64d4e15-00.mono-fallback";
    #audioSource = "vsink_fx_mic.monitor"; # AEC
    audioSource = "nui_mic_remap";
    audioAlert = "alsa_output.pci-0000_00_03.0.hdmi-stereo-extra1";
  };
}
