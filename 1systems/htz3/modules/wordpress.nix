{ config, lib, pkgs, ... }:

let
  domain = "int.fraam.de";
in
{

  services.wordpress.sites."fraam" = {
    database.createLocally = true;
    webserver = "nginx";
  };

  services.nginx.virtualHosts."fraam" = {

  };

  ptsd.nwtraefik.services = [
    {
      name = "wordpress";
      rule = "Host(`${domain}`)";
      auth.forwardAuth = {
        address = "http://localhost:4181";
        authResponseHeaders = [ "X-Forwarded-User" ];
      };
      entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
    }
  ];



}
