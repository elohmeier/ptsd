{ pkgs, ... }:
{
  imports = [
    ../../2configs/home
    ../../2configs/home/extraTools.nix
    ../../2configs/home/gpg.nix
  ];

  home.stateVersion = "20.09";

  # disable touchpad
  xsession.windowManager.i3.extraConfig = ''
    exec ${pkgs.xorg.xinput}/bin/xinput disable "Synaptics TM3381-002"
  '';

  wayland.windowManager.sway = {
    config.input."1739:0:Synaptics_TM3381-002".events = "disabled";
    extraConfig = ''
      output eDP-1 pos 0 0 mode 1920x1080@70.001Hz scale 1.3
    '';
  };

  # ptsd.baresip = {
  #   enable = true;
  #   username = "tp1baresip";
  #   registrar = "192.168.178.1";
  #   password = baresipSecrets.password;
  #   netInterface = "nwvpn";

  #   # FBD
  #   # audioPlayer = "alsa_output.usb-Plantronics_Savi_8220-M_9C9BFA234CF842DDA69AFAA8BA1AF13E-01.analog-stereo";
  #   # audioSource = "alsa_input.usb-Plantronics_Savi_8220-M_9C9BFA234CF842DDA69AFAA8BA1AF13E-01.analog-stereo";

  #   # QC35
  #   audioPlayer = "bluez_sink.04_52_C7_0C_C1_61.headset_head_unit";
  #   audioSource = "bluez_source.04_52_C7_0C_C1_61.headset_head_unit";

  #   audioAlert = "alsa_output.pci-0000_00_1f.3.analog-stereo";
  # };
}
