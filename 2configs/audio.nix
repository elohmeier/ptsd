{ config, lib, pkgs, ... }:

{
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = lib.mkDefault pkgs.pulseaudioFull; # pulseAudioFull required for bluetooth audio support
    #support32Bit = true; # for Steam

    # better audio quality settings
    # from https://medium.com/@gamunu/enable-high-quality-audio-on-linux-6f16f3fe7e1f
    daemon.config = {
      default-sample-format = "float32le";
      default-sample-rate = lib.mkDefault 48000;
      alternate-sample-rate = 44100;
      default-sample-channels = 2;
      default-channel-map = "front-left,front-right";
      resample-method = "speex-float-10";
      enable-lfe-remixing = "no";
      high-priority = "yes";
      nice-level = -11;
      realtime-scheduling = "yes";
      realtime-priority = 9;
      rlimit-rtprio = 9;
    };
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
    pasystray
  ];

  systemd.user.services.pasystray = lib.mkIf config.services.xserver.enable {
    description = "PulseAudio system tray";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    path = [ pkgs.pavucontrol ];
    serviceConfig = {
      # Workaround from https://github.com/NixOS/nixpkgs/issues/7329 to make GTK-Themes work
      ExecStart = "${pkgs.bash}/bin/bash -c 'source ${config.system.build.setEnvironment}; exec ${pkgs.pasystray}/bin/pasystray'";
      RestartSec = 3;
      Restart = "always";
    };
  };
}
