{ config, lib, pkgs, ... }:
let
  domain = "ci.nerdworks.de";
in
{
  ptsd.drone-server = {
    enable = true;
    port = config.ptsd.nwtraefik.ports.droneci;
    envConfig = {
      DRONE_USER_CREATE = "username:enno,admin:true";
      DRONE_AGENTS_ENABLED = "true";
      DRONE_SERVER_HOST = domain;
      DRONE_SERVER_PROTO = "https";
      DRONE_GITEA_SERVER = "https://git.nerdworks.de";
      DRONE_GIT_ALWAYS_AUTH = "false";
      # these secrets are contained in the .env file
      #DRONE_GITEA_CLIENT_ID = ...;
      #DRONE_GITEA_CLIENT_SECRET = ...;
      #DRONE_RPC_SECRET = ...; # Use `hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random` to generate.
    };
    envFile = config.ptsd.secrets.files."drone-ci.env".path;
  };

  ptsd.secrets.files."drone-ci.env" = {
    dependants = [ "drone-server.service" ];
  };

  ptsd.lego.extraDomains = [
    domain
  ];

  ptsd.nwtraefik.services = [
    {
      name = "droneci";
      rule = "Host:${domain}";
    }
  ];
}
