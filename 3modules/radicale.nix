{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.radicale;

  confFile = pkgs.writeText "radicale.conf" (
    generators.toINI
      { }
      {
        server = {
          hosts = "127.0.0.1:${toString cfg.port}";
        };

        auth = {
          type = "htpasswd";
          htpasswd_filename = cfg.htpasswd;
          htpasswd_encryption = "bcrypt";
        };

        storage = {
          filesystem_folder = "/var/lib/radicale/collections";
          hook = ''${pkgs.git}/bin/git add -A && (git diff --cached --quiet || ${pkgs.git}/bin/git commit -m "Changes by "%(user)s)'';
        };

        logging = {
          debug = "true";
        };
      }
  );

  gitignore = pkgs.writeText "gitignore" ''
    .Radicale.cache
    .Radicale.lock
    .Radicale.tmp-*
  '';
in
{

  options = {
    ptsd.radicale = {
      enable = mkEnableOption "radicale";
      port = mkOption {
        type = types.int;
      };
      # generate using {pkgs.apacheHttpd}/bin/htpasswd -bcB "$out" USER PWD
      htpasswd = mkOption {
        type = types.path;
        description = "htpasswd authentication file, bcrypt encryption is expected";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ radicale2 ];

    systemd.services.radicale = {
      description = "A Simple Calendar and Contact Server";
      after = [ "network.target" ];
      requires = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        ${pkgs.coreutils}/bin/mkdir -p "$STATE_DIRECTORY/collections"
        ${pkgs.git}/bin/git -C "$STATE_DIRECTORY/collections" init .
        ${pkgs.coreutils}/bin/cp ${gitignore} "$STATE_DIRECTORY/collections/.gitignore"
        ${pkgs.coreutils}/bin/chmod o+w "$STATE_DIRECTORY/collections/.gitignore"
      '';
      serviceConfig = {
        ExecStart = "${pkgs.radicale2}/bin/radicale -C ${confFile}";
        DynamicUser = true;
        StateDirectory = "radicale";
        Restart = "on-failure";
        # Deny other users access to the calendar data
        UMask = "0027";
        PrivateTmp = "true";
        ProtectSystem = "full";
        ProtectHome = "true";
        PrivateDevices = "true";
        NoNewPrivileges = "true";
        RuntimeDirectory = "radicale";
      };
    };
  };
}
