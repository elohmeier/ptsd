{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.fraamdb;
  fraamdb = pkgs.callPackage
    (pkgs.fetchgit {
      url = "https://git.fraam.de/fraam/fraamdb.git";
      #rev = "refs/tags/${version}";
      rev = "c3d6c19fba36b4a610a67eb1c88990787e6bb84f";
      sha256 = "1f8chvcx3kg5y0kyp948j1zl5dixq06ifyqamz1d5kpq7vikcn4i";
    })
    { };
  pyenv = fraamdb.python.withPackages (ps: [ fraamdb ps.gunicorn ]);
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
        PYTHONPATH = "${pyenv}/${pyenv.python.sitePackages}/";
        ALLOWED_HOSTS = "localhost"; # TODO
        SECRET_KEY = ""; # TODO from file
        GOOGLE_OAUTH2_SECRET = ""; # TODO from file
        DEBUG = "1"; # TODO
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
