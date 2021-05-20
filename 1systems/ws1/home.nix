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
      output DP-2 pos 0 0 mode 3840x2160@59.997002Hz scale 1.859375
      output DP-4 pos 2064 0 mode 3840x2160@59.997002Hz scale 1.859375
    '';

    # extraConfig = ''
    #   output DP-4 pos 0 1052 mode 3840x2160@59.997002Hz scale 1.859375
    #   output DP-8 pos 0 0 mode 4096x2304@59.999001Hz scale 2.191406
    #   output DP-2 pos 2064 1052 mode 3840x2160@59.997002Hz scale 1.859375
    # '';

    # both on nvidia:
    # extraConfig = ''
    #   output DP-3 pos 0 0 mode 3840x2160@59.997002Hz scale 2
    #   output DP-4 pos 1920 0 mode 3840x2160@59.999001Hz scale 2
    # '';
  };

  # ptsd.baresip = {
  #   enable = true;
  #   username = "ws1linphone";
  #   registrar = "192.168.178.1";
  #   password = baresipSecrets.password;

  #   # QC35
  #   # audioPlayer = "bluez_sink.04_52_C7_0C_C1_61.headset_head_unit";
  #   # audioSource = "bluez_source.04_52_C7_0C_C1_61.headset_head_unit";

  #   # Steinberg
  #   audioPlayer = "alsa_output.usb-Yamaha_Corporation_Steinberg_UR44C-00.analog-surround-21";

  #   # Cam
  #   # audioSource = "alsa_input.usb-046d_HD_Pro_Webcam_C920_F31F411F-02.analog-stereo";

  #   # Cam AEC
  #   #audioSource = "alsa_input.usb-046d_HD_Pro_Webcam_C920_F31F411F-02.analog-stereo.echo-cancel";
  #   audioSource = "vsink_fx_mic.monitor";

  #   audioAlert = "alsa_output.usb-LG_Electronics_Inc._USB_Audio-00.analog-stereo";
  # };

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
