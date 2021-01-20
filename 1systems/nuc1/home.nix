{ config, lib, pkgs, ... }:
let
  baresipSecrets = import <secrets/baresip.nix>;
  homeSecrets = import <client-secrets/home-secrets.nix>;
  todoistSecrets = import <secrets/todoist.nix>;
in
{
  imports = [
    <ptsd/2configs/home>
    <ptsd/2configs/home/extraTools.nix>
    <ptsd/2configs/home/firefox.nix>
    <ptsd/2configs/home/gpg.nix>
  ];


  wayland.windowManager.sway.extraConfig = ''
    output HDMI-A-1 pos 0 0 mode 2560x1440@59.951000Hz scale 1
    output HDMI-A-2 pos 2560 0 mode 1920x1200@59.950001Hz scale 1
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

  ptsd.nwi3status = {
    todoistApiKey = todoistSecrets.todoistApiKey;
    showBatteryStatus = false;
    showNvidiaGpuStatus = false;
    ethIf = "wlan0";
    extraDiskBlocks = [
      {
        block = "disk_space";
        path = "/home";
        alias = "/home";
        warning = 5;
        alert = 1;
      }
      {
        block = "disk_space";
        path = "/persist";
        alias = "/persist";
        warning = 0.5;
        alert = 0.2;
      }
      {
        block = "disk_space";
        path = "/var/src";
        alias = "/var/src";
        warning = 0.3;
        alert = 0.1;
      }
      {
        block = "disk_space";
        path = "/nix";
        alias = "/nix";
        warning = 5;
        alert = 1;
      }
      {
        block = "disk_space";
        path = "/tmp";
        alias = "/tmp";
        warning = 5;
        alert = 1;
      }
    ];
  };

  home = {
    packages = with pkgs; [
      pdfduplex
      pdf2svg
    ];
  };
}
