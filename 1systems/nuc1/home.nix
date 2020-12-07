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
    <ptsd/2configs/home/weatherbg.nix>
    <ptsd/2configs/home/xsession-i3.nix>
  ];

  ptsd.baresip = {
    enable = true;
    username = "nuc1baresip";
    registrar = "192.168.178.1";
    password = baresipSecrets.password;
    netInterface = "nwvpn";
    audioPlayer = "alsa_output.usb-Plantronics_Plantronics_Voyager_Base_CD_f169d9bb77a148e4b7e910d4a64d4e15-00.analog-stereo";
    audioSource = "alsa_input.usb-Plantronics_Plantronics_Voyager_Base_CD_f169d9bb77a148e4b7e910d4a64d4e15-00.mono-fallback";
    audioAlert = "alsa_output.pci-0000_00_03.0.hdmi-stereo-extra1";
  };

  ptsd.alacritty = {
    enable = true;
    fontName = "Cozette";
  };
  ptsd.i3 = {
    configureGtk = true;
    configureRofi = true;
    fontMono = "Cozette";
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
