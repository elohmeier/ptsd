{ pkgs, ... }:
let
  baresipSecrets = import <secrets/baresip.nix>;
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd/2configs/home>
    <ptsd/2configs/home/baseX.nix>
    <ptsd/2configs/home/extraTools.nix>
    <ptsd/2configs/home/sway.nix>
    <ptsd/2configs/home/xsession-i3.nix>
  ];

  wayland.windowManager.sway.config.input = {
    "1:1:AT_Translated_Set_2_keyboard" = {
      xkb_layout = "de";
    };

    "1739:0:Synaptics_TM3381-002" = {
      natural_scroll = "enabled";
    };
  };

  ptsd.i3 = {
    showBatteryStatus = true;
    showWifiStatus = true;
    configureGtk = false;
    configureRofi = false;
  };
  ptsd.sway = {
    showBatteryStatus = true;
    showWifiStatus = true;
  };

  #home.packages = [ pkgs.steam ];

  xsession.initExtra = ''
    # will dim after 10 mins, lock 5 sec after.
    # see xss-lock configuration for details.
    ${pkgs.xorg.xset}/bin/xset s 600 5
  '';

  ptsd.baresip = {
    enable = true;
    username = "tp1baresip";
    registrar = "192.168.178.1";
    password = baresipSecrets.password;
    netInterface = "nwvpn";

    # FBD
    audioPlayer = "alsa_output.usb-Plantronics_Savi_8220-M_9C9BFA234CF842DDA69AFAA8BA1AF13E-01.analog-stereo";
    audioSource = "alsa_input.usb-Plantronics_Savi_8220-M_9C9BFA234CF842DDA69AFAA8BA1AF13E-01.analog-stereo";

    audioAlert = "alsa_output.pci-0000_00_1f.3.analog-stereo";
  };
}
