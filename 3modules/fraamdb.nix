{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.fraamdb;
  py3 = pkgs.python3.override {
    packageOverrides = self: super: rec {
      django = self.django_3;
      fraamdb = self.callPackage ../5pkgs/fraamdb { };
      monday = self.callPackage ../5pkgs/monday { };
    };
  };
  pyenv = py3.withPackages (
    pythonPackages: with pythonPackages; [
      fraamdb
      psycopg2
      gunicorn
    ]
  );
in
{
  options = {
    ptsd.fraamdb = {
      enable = mkEnableOption "fraamdb";
    };
  };

  config = mkIf cfg.enable {

    systemd.services.fraamdb = {
      description = "fraamdb django app";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" "postgresql.service" ];
      after = [ "network.target" "postgresql.service" ];

      environment = {
        DATABASE_URL = "sqlite:////var/lib/fraamdb/fraamdb.sqlite";
        PYTHONPATH = "${pyenv}/${py3.sitePackages}/";
      };

      script = ''
        ${pyenv}/bin/manage.py migrate
        ${pyenv}/bin/gunicorn fraamdb.wsgi \
          -b 0.0.0.0:8000 \
          --workers=2 \
          --threads=2
      '';

      serviceConfig = {
        DynamicUser = true;
        CapabilityBoundingSet = "cap_net_bind_service";
        LockPersonality = true;
        RestrictAddressFamilies = "AF_INET AF_INET6";
        NoNewPrivileges = true;
        StateDirectory = "fraamdb";
      };
    };
  };
}
