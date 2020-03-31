{ config, lib, pkgs, ... }:

{
  services.nginx = {
    enable = true;

    commonHttpConfig = ''
      charset UTF-8;
    '';

    virtualHosts = {
      # vHost to be protected
      "htz2.host.nerdworks.de" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = config.ptsd.nwtraefik.ports.nginx-htz2;
          }
        ];
        locations."/" = {
          extraConfig = ''
            return 200 'private area';
          '';
        };
      };
    };
  };

  ptsd.traefik-forward-auth = {
    enable = true;
    envFile = toString <secrets/traefik-forward-auth.env>;
  };

  ptsd.nwtraefik.services = [
    {
      name = "nginx-htz2";
      rule = "Host:htz2.host.nerdworks.de";
      auth.forward = {
        address = "http://localhost:4181";
        authResponseHeaders = [ "X-Forwarded-User" ];
      };
    }
  ];
}
