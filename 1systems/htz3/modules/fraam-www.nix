{ config, lib, pkgs, ... }:

with lib;
{
  services.mysqlBackup = {
    enable = true;
    databases = [ "wordpress" ];
  };

  ptsd.nwtraefik.services = [
    {
      name = "fraam-wordpress-auth";
      rule = "Host(`dev.fraam.de`)";
      url = "http://localhost:${toString config.ptsd.ports.fraam-wordpress}";
      auth.forwardAuth = {
        address = "http://localhost:4181";
        authResponseHeaders = [ "X-Forwarded-User" ];
      };
      entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
    }
    {
      # required for ../5pkgs/fraam-update-static-web access
      # host entry to 127.0.0.1 needs to be set
      name = "fraam-wordpress-local";
      rule = "Host(`dev.fraam.de`)";
      url = "http://localhost:${toString config.ptsd.ports.fraam-wordpress}";
      entryPoints = [ "loopback4-https" ];
    }
    {
      name = "fraam-wwwstatic";
      rule = "Host(`www.fraam.de`) || Host(`fraam.de`)";
      entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
    }
    {
      name = "gowpcontactform";
      rule = "PathPrefix(`/wp-json/contact-form-7/`) && (Host(`www.fraam.de`) || Host(`fraam.de`))";
      entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
    }
  ];

  ptsd.traefik-forward-auth = {
    enable = true;
    envFile = "/var/src/secrets/traefik-forward-auth.env";
  };

  environment.systemPackages = with pkgs; [
    (
      writers.writeDashBin "fraam-update-static-web" ''
        ROOT="''${1?must provide static root}"

        # fetch website
        ${wget}/bin/wget --mirror --page-requisites --no-parent --directory-prefix="$ROOT" --no-host-directories https://dev.fraam.de
        ${wget}/bin/wget --mirror --page-requisites --no-parent --directory-prefix="$ROOT" --no-host-directories https://dev.fraam.de/karriere/
        ${wget}/bin/wget --mirror --page-requisites --no-parent --directory-prefix="$ROOT" --no-host-directories https://dev.fraam.de/impressum/
        ${wget}/bin/wget --mirror --page-requisites --no-parent --directory-prefix="$ROOT" --no-host-directories https://dev.fraam.de/pentests/

        # remove absolute links
        ${findutils}/bin/find "$ROOT" -type f -exec ${gnused}/bin/sed -i 's/https:\/\/dev.fraam.de\//\//g' {} +
        ${findutils}/bin/find "$ROOT" -type f -exec ${gnused}/bin/sed -i 's/https:\\\/\\\/dev.fraam.de\\\//\\\//g' {} +
        ${findutils}/bin/find "$ROOT" -type f -exec ${gnused}/bin/sed -i 's/https:\/\/fraam.de\//\//g' {} +

        # fix missing slash in impressum link
        ${findutils}/bin/find "$ROOT" -type f -name "*.html" -exec ${gnused}/bin/sed -i 's/"\/impressum"/"\/impressum\/"/g' {} +

        # remove ?ver=... suffices from css/js files
        ${findutils}/bin/find "$ROOT" -type f -name "*?ver=*" | ${findutils}/bin/xargs -I % sh -c 'newname=$(echo % | ${gnused}/bin/sed "s/?ver=.*//"); ${coreutils}/bin/mv % $newname'
      ''
    )
  ];

  systemd.services.gowpcontactform = {
    description = "gowpcontactform";
    wants = [ "network.target" ];
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''${pkgs.gowpcontactform}/bin/gowpcontactform \
                      -listen localhost:${toString config.ptsd.ports.gowpcontactform}'';
      DynamicUser = true;
      Restart = "on-failure";
      StartLimitBurst = 5;
      AmbientCapabilities = "cap_net_bind_service";
      CapabilityBoundingSet = "cap_net_bind_service";
      NoNewPrivileges = true;
      LimitNPROC = 64;
      LimitNOFILE = 1048576;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectControlGroups = true;
      ProtectClock = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictAddressFamilies = "AF_INET AF_INET6";
      RestrictNamespaces = true;
      DevicePolicy = "closed";
      RestrictRealtime = true;
      SystemCallFilter = "@system-service";
      SystemCallErrorNumber = "EPERM";
      SystemCallArchitectures = "native";
    };
    unitConfig = {
      StartLimitInterval = 86400;
    };
  };
}
