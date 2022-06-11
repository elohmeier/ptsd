{ config, lib, pkgs, ... }:

{
  programs.gpg = {
    enable = true;
    settings.throw-keyids = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = pkgs.stdenv.isLinux;
    extraConfig = ''
      # https://github.com/drduh/config/blob/master/gpg-agent.conf
      # https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html
      default-cache-ttl 60
      max-cache-ttl 120
    '';
    pinentryFlavor = if pkgs.stdenv.isLinux then "gnome3" else "tty";
  };
}
