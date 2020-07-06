{ config, lib, pkgs, ... }:

{
  services.nginx = {
    enable = true;

    commonHttpConfig = ''
      charset UTF-8;
      types_hash_max_size 4096;
      server_names_hash_bucket_size 128;
    '';

    virtualHosts = {
      # vHost to be protected
      "htz3.host.fraam.de" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = config.ptsd.nwtraefik.ports.nginx-htz3;
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
      name = "nginx-htz3";
      rule = "Host:htz3.host.fraam.de";
      auth.forward = {
        address = "http://localhost:4181";
        authResponseHeaders = [ "X-Forwarded-User" ];
      };
    }
  ];
}
