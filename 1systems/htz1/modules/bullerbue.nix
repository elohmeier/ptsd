{ config, lib, pkgs, ... }:

{
  services.nginx.virtualHosts = {
    "xn--bullerb-in-hamburg-s6b.de" = {
      listen = [{ addr = "127.0.0.1"; port = 9875; }];
      globalRedirect = "www.xn--bullerb-in-hamburg-s6b.de";
    };
    "www.xn--bullerb-in-hamburg-s6b.de" = {
      listen = [{ addr = "127.0.0.1"; port = 9875; }];
      root = "/var/www/bullerbue";
    };
  };

  ptsd.nwtraefik.services = [{
    name = "bullerbue";
    rule = "Host(`xn--bullerb-in-hamburg-s6b.de`) || Host(`www.xn--bullerb-in-hamburg-s6b.de`)";
    entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
    url = "http://127.0.0.1:9875";
  }];
}
