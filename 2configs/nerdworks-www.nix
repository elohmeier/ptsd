{ config, lib, pkgs, ... }:
let
  mynginx = pkgs.nginx.override {
    modules = with pkgs.nginxModules; [ fancyindex ];
  };
in
{
  services.nginx = {
    enable = true;

    commonHttpConfig = ''
      charset UTF-8;
      types_hash_max_size 4096;
      server_names_hash_bucket_size 128;
    '';

    virtualHosts = {

      "www.nerdworks.de" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = config.ptsd.nwtraefik.ports.nerdworkswww;
          }
        ];
        root = "/var/www/nerdworks.de/prod-v2";
        locations."/dl/" = {
          alias = "/var/www/nerdworks.de/dl/";
          #extraConfig = ''
          #  fancyindex on;
          #  fancyindex_exact_size off;
          #'';
        };
      };

      "nerdworks.de" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = config.ptsd.nwtraefik.ports.nerdworkswww;
          }
        ];
        globalRedirect = "www.nerdworks.de";
      };

    };

    #package = mynginx;
  };

  ptsd.nwtraefik.services = [
    {
      name = "nerdworkswww";
      rule = "Host(`nerdworks.de`) || Host(`www.nerdworks.de`)";
      entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
    }
  ];
}
