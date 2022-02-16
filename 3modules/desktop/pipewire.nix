{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.desktop;
in
{
  sound.enable = cfg.audio.enable && !config.ptsd.bootstrap;

  services.pipewire = mkIf (cfg.enable && cfg.audio.enable && !config.ptsd.bootstrap) {
    enable = true;
    alsa.enable = mkIf (!config.ptsd.minimal) true;
    alsa.support32Bit = mkIf (!config.ptsd.minimal) true;
    jack.enable = mkIf (!config.ptsd.minimal) true;
    pulse.enable = true;
    media-session = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; optionals (cfg.audio.enable && !config.ptsd.minimal) [
    pamixer
    playerctl
    #cadence
    qjackctl
    config.hardware.pulseaudio.package
    pavucontrol
    jack2
  ];
}
