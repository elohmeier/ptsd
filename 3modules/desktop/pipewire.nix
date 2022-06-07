{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.desktop;
in
{
  sound.enable = cfg.audio.enable;

  services.pipewire = mkIf (cfg.enable && cfg.audio.enable) {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; optionals (cfg.audio.enable) [
    pamixer
    playerctl
    qjackctl
    config.hardware.pulseaudio.package
    pavucontrol
    jack2
  ];
}
