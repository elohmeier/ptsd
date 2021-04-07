{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.fraamdb;
  gitRef = (lib.importJSON ./fraamdb.json);
  src = pkgs.fetchgit {
    url = "https://git.fraam.de/fraam/fraamdb.git";
    rev = "refs/tags/${gitRef.version}";
    sha256 = gitRef.sha256;
  };
  #src = pkgs.nix-gitignore.gitignoreSourcePure [ /home/enno/repos/fraamdb/.gitignore ] /home/enno/repos/fraamdb;
  fraamdb = pkgs.callPackage (src) { };
  pyenv = fraamdb.python.withPackages (ps: [ fraamdb ps.gunicorn ]);
  manage = pkgs.writeShellScript "fraamdb-manage" ''
    export DJANGO_SETTINGS_MODULE="fraamdb.settings";    
    export DATABASE_URL="sqlite:////var/lib/fraamdb/fraamdb.sqlite";
    ${pyenv}/bin/manage.py ''${@:1}
  '';
in
{
  # run `/var/lib/fraamdb/manage createsuperuser` as root to create an admin user

  options = {
    ptsd.fraamdb = {
      enable = mkEnableOption "fraamdb";
      allowedHosts = mkOption {
        type = types.str;
        default = "localhost";
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.fraamdb = {
      description = "fraamdb django app";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
      after = [ "network.target" ];

      environment = {
        DJANGO_SETTINGS_MODULE = "fraamdb.settings";
        PYTHONPATH = "${pyenv}/${pyenv.python.sitePackages}/";
        DATABASE_URL = "sqlite:////var/lib/fraamdb/fraamdb.sqlite";
        ALLOWED_HOSTS = cfg.allowedHosts;
        STATIC_ROOT = fraamdb.static;
        DEBUG = "0";
      };

      preStart = ''
        if [[ $(readlink /var/lib/fraamdb/manage) != "${manage}" ]]; then
          ln -sf "${manage}" /var/lib/fraamdb/manage
        fi
      '';

      script = ''
        ${pyenv}/bin/manage.py migrate
        ${pyenv}/bin/gunicorn fraamdb.wsgi \
          -b 0.0.0.0:8000 \
          --workers=2 \
          --threads=2
      '';

      serviceConfig = {
        EnvironmentFile = "/var/src/secrets/fraamdb.env";
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
