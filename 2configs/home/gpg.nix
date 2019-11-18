{ config, pkgs, ... }:

{

  programs.gpg = {
    enable = true;
    settings.throw-keyids = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    extraConfig = ''
      # https://github.com/drduh/config/blob/master/gpg-agent.conf
            # https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html
                  default-cache-ttl 60
                        max-cache-ttl 120
    '';
  };
}
