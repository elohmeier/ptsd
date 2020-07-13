{ config, lib, pkgs, ... }:
let
  #homeSecrets = import /run/keys/home-secrets.nix;
  homeSecrets = import <client-secrets/home-secrets.nix>;
in
{
  imports = [
    <ptsd/2configs/home>
    <ptsd/2configs/home/baseX.nix>
    <ptsd/2configs/home/extraTools.nix>
    <ptsd/2configs/home/xsession-i3.nix>
  ];

  ptsd.urxvt.theme = "solarized_dark";

  ptsd.baresip = {
    enable = true;
    username = "ws1linphone";
    registrar = "192.168.178.1";
    password = homeSecrets.baresip_pw;
  };

  ptsd.i3 = {
    showBatteryStatus = false;
    showWifiStatus = false;
    showNvidiaGpuStatus = true;
    ethIf = "br0";
    extraDiskBlocks = [
      {
        block = "disk_space";
        path = "/var";
        alias = "/var";
        warning = 1;
        alert = 0.5;
      }
      {
        block = "disk_space";
        path = "/var/lib/docker";
        alias = "/var/lib/docker";
        warning = 2;
        alert = 1;
      }
      {
        block = "disk_space";
        path = "/var/lib/libvirt/images";
        alias = "/var/lib/libvirt/images";
        warning = 2;
        alert = 1;
      }
      {
        block = "disk_space";
        path = "/var/log";
        alias = "/var/log";
        warning = 1;
        alert = 0.5;
      }
    ];
  };

  home = {
    file.".baresip/contacts".text = homeSecrets.baresip_contacts;
    file.".baresip/uuid".text = ''2e3a60c7-c86f-af8f-591a-9d1903d9d5dc'';

    packages = with pkgs; [
      prusa-slicer
      freecad
    ];
  };

  xsession.initExtra = ''
    # disable screensaver
    ${pkgs.xorg.xset}/bin/xset s off -dpms
  '';
}
