{ config, pkgs, ... }:

{

  programs.gpg = {
    enable = true;
    settings.throw-keyids = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    extraConfig = ''
      # https://github.com/drduh/config/blob/master/gpg-agent.conf
      # https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html
      default-cache-ttl 60
      max-cache-ttl 120
    '';
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "ws1-osx" = {
        hostname = "192.168.178.61";
        forwardAgent = true;
        extraOptions.RemoteForward = "/Users/enno/.gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra";
      };
    };
  };
}
