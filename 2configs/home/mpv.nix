{ config, lib, pkgs, nixosConfig, ... }:

{
  programs.mpv = {
    enable = !nixosConfig.ptsd.minimal;
    config = {
      hwdec = "auto-safe";
      vo = "gpu";
      profile = "gpu-hq";
      gpu-context = "wayland";
      ytdl-format = "bestvideo+bestaudio";
    };
    scripts = [ pkgs.mpvScripts.mpris ];
  };
}
