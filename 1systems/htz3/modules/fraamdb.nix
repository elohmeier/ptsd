{ config, lib, pkgs, ... }:

let
  domain = "db.fraam.de";
in
{
  services.fraamdb = {
    inherit domain;
    enable = true;
    bind = "127.0.0.1:${toString config.ptsd.ports.fraamdb}";
    envFile = "/var/src/secrets/fraamdb.env";
    googleJson = "/var/src/secrets/google-service-fraamdb.json";
    debug = false;
  };

  ptsd.nwtraefik.services = [
    {
      name = "fraamdb";
      rule = "Host(`${domain}`)";
      auth.forwardAuth = {
        address = "http://localhost:4181";
        authResponseHeaders = [ "X-Forwarded-User" ];
      };
      entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
    }
  ];
}
