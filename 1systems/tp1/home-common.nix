{ pkgs, ... }:
let
  baresipSecrets = import <secrets/baresip.nix>;
  universe = import <ptsd/2configs/universe.nix>;
  todoistSecrets = import <secrets/todoist.nix>;
in
{
  imports = [
    <ptsd/2configs/home>
    <ptsd/2configs/home/extraTools.nix>
    <ptsd/2configs/home/firefox.nix>
    <ptsd/2configs/home/gpg.nix>

    # disabled, waiting for https://github.com/nix-community/home-manager/pull/1614
    # <ptsd/2configs/home/sway.nix>

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

  xsession.windowManager.i3.extraConfig = ''
    exec ${pkgs.xorg.xinput}/bin/xinput disable "Synaptics TM3381-002"
  '';

  ptsd.kitty = {
    enable = true;
    fontName = "ProggyCleanTT";
    fontSize = 9;
  };
  ptsd.i3 = {
    configureGtk = true;
    configureRofi = true;
    fontName = "ProggyCleanTT";
    fontSize = 9;
  };
  ptsd.sway = {
    configureGtk = false;
    configureRofi = false;
    fontName = "ProggyCleanTT";
    fontSize = 9;
  };
  ptsd.nwi3status = {
    todoistApiKey = todoistSecrets.todoistApiKey;
    showBatteryStatus = true;
    wifiIf = "wlan0";
    extraDiskBlocks = [{
      block = "disk_space";
      path = "/home";
      alias = "/h";
      warning = 5;
      alert = 1;
    }
      {
        block = "disk_space";
        path = "/persist";
        alias = "/p";
        warning = 0.5;
        alert = 0.2;
      }
      {
        block = "disk_space";
        path = "/var/src";
        alias = "/v/s";
        warning = 0.3;
        alert = 0.1;
      }
      {
        block = "disk_space";
        path = "/nix";
        alias = "/n";
        warning = 5;
        alert = 1;
      }
      {
        block = "disk_space";
        path = "/tmp";
        alias = "/t";
        warning = 5;
        alert = 1;
      }];
  };

  home.packages = with pkgs;[
    # steam
    pdfduplex
    pdf2svg
    epsxe
    mupen64plus
    wine
    winetricks
    ppsspp
  ];

  # epsxe
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.0.2u"
  ];

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
    # audioPlayer = "alsa_output.usb-Plantronics_Savi_8220-M_9C9BFA234CF842DDA69AFAA8BA1AF13E-01.analog-stereo";
    # audioSource = "alsa_input.usb-Plantronics_Savi_8220-M_9C9BFA234CF842DDA69AFAA8BA1AF13E-01.analog-stereo";

    # QC35
    audioPlayer = "bluez_sink.04_52_C7_0C_C1_61.headset_head_unit";
    audioSource = "bluez_source.04_52_C7_0C_C1_61.headset_head_unit";

    audioAlert = "alsa_output.pci-0000_00_1f.3.analog-stereo";
  };
}
