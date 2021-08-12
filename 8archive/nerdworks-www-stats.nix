{ config, lib, pkgs, ... }:
let
  reportDir = "/var/www/nerdworks.de/report/";
in
{
  services.nginx.virtualHosts."www.nerdworks.de".locations."/besoekers/".alias = reportDir;

  environment.systemPackages = [ pkgs.goaccess ];

  users.groups.traefik.members = [ "nginx" ];

  systemd.services."goaccess-traefik" = {
    description = "generate goaccess report for traefik access.log";

    script = ''
      ${pkgs.goaccess}/bin/goaccess \
        --geoip-database=${pkgs.geolite2}/share/geoip/GeoLite2-City.mmdb \
        --log-format='%h %^ %e [%d:%t %^] "%r" %s %b "%R" "%u" %^ "%v" %^ %Lms' \
        --date-format=%d/%b/%Y \
        --time-format=%T \
        -o ${reportDir}/index.html \
        /var/lib/traefik/access.log
    '';
    serviceConfig = {
      ExecStartPre = ''+${pkgs.coreutils}/bin/install -d -m 0755 -o traefik -g traefik "${reportDir}"'';
      User = "traefik";
      Group = "traefik";
      ProtectHome = true;
      ProtectSystem = "full";
      Restart = "on-failure";
      RestartSec = "5sec";
    };
    startAt = "hourly";
  };
}
