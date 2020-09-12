{ config, lib, pkgs, ... }:
let
  baresipSecrets = import <secrets/baresip.nix>;
  homeSecrets = import <client-secrets/home-secrets.nix>;
  unstable = import <nixpkgs-unstable> {
    config = {
      allowUnfree = true;
    };
  };
in
{
  imports = [
    <ptsd/2configs/home>
    <ptsd/2configs/home/baseX.nix>
    <ptsd/2configs/home/extraTools.nix>
    <ptsd/2configs/home/weatherbg.nix>
    <ptsd/2configs/home/xsession-i3.nix>
  ];

  ptsd.urxvt.theme = "solarized_dark";

  ptsd.baresip = {
    enable = true;
    username = "ws1linphone";
    registrar = "192.168.178.1";
    password = baresipSecrets.password;

    # QC35
    # audioPlayer = "bluez_sink.04_52_C7_0C_C1_61.headset_head_unit";
    # audioSource = "bluez_source.04_52_C7_0C_C1_61.headset_head_unit";

    # Steinberg
    audioPlayer = "alsa_output.usb-Yamaha_Corporation_Steinberg_UR44C-00.analog-surround-21";

    # Cam
    # audioSource = "alsa_input.usb-046d_HD_Pro_Webcam_C920_F31F411F-02.analog-stereo";

    # Cam AEC
    audioSource = "alsa_input.usb-046d_HD_Pro_Webcam_C920_F31F411F-02.analog-stereo.echo-cancel";

    audioAlert = "alsa_output.usb-LG_Electronics_Inc._USB_Audio-00.analog-stereo";
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
    packages = with pkgs; [
      unstable.prusa-slicer
      freecad
    ];
  };

  xsession.initExtra = ''
    # disable screensaver
    ${pkgs.xorg.xset}/bin/xset s off -dpms
  '';
}
