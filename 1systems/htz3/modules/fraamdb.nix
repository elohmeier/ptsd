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

  services.nginx.virtualHosts."${domain}".locations."/".extraConfig = ''
    proxy_pass http://127.0.0.1:${toString config.ptsd.ports.fraamdb};
  '';
}
