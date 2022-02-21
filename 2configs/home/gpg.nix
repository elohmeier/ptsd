{ config, lib, pkgs, nixosConfig, ... }:

{

  programs.gpg = {
    enable = !nixosConfig.ptsd.minimal;
    settings.throw-keyids = true;
  };

  services.gpg-agent = {
    enable = !nixosConfig.ptsd.minimal;
    enableSshSupport = true;
    enableExtraSocket = true;
    extraConfig = ''
      # https://github.com/drduh/config/blob/master/gpg-agent.conf
      # https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html
      default-cache-ttl 60
      max-cache-ttl 120
    '';
    pinentryFlavor = "gnome3";
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      #"ws1-osx" = {
      #  hostname = "192.168.178.61";
      #  forwardAgent = true;
      #  extraOptions.RemoteForward = "/Users/enno/.gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra";
      #};

      "htz3-1022" = {
        #hostname = "191.18.19.41";
        hostname = "htz3.host.fraam.de";
        port = 1022;
      };

      "fbdjmp" = {
        hostname = "192.168.178.135";
        user = "sysadmin";
        port = 12345;
      };

      #"awsbuilder" = {
      #  hostname = "35.157.132.66";
      #  user = "admin";
      #  identityFile = "/var/src/secrets/ssh.id_ed25519";
      #};
    };
  };
}
