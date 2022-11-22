{ config, lib, pkgs, ... }:

let
  pkg = pkgs.paperless-ngx;
  dataDir = "${config.xdg.dataHome}/paperless";

  env = {
    PAPERLESS_DATA_DIR = dataDir;
    PAPERLESS_CONSUMPTION_DIR = "${dataDir}/consume";
    PAPERLESS_MEDIA_ROOT = "${dataDir}/media";
    PAPERLESS_REDIS = "unix://${config.xdg.dataHome}/redis-paperless/redis.sock";
    GUNICORN_CMD_ARGS = "--bind=127.0.0.1:9876 --worker-tmp-dir=/tmp";
  };

  # utility function around makeWrapper
  mkWrapperDrv = { original, name, set ? { } }:
    pkgs.runCommand "${name}-wrapper" { nativeBuildInputs = [ pkgs.makeWrapper ]; } (with lib; ''
      makeWrapper "${original}" "$out/bin/${name}" \
        ${concatStringsSep " \\\n " (mapAttrsToList (name: value: ''--set ${name} "${value}"'') set)}
    '');

  mkValueString = value:
    if value == true then "yes"
    else if value == false then "no"
    else lib.generators.mkValueStringDefault { } value;

  redisConfig = settings: pkgs.writeText "redis.conf" (lib.generators.toKeyValue
    {
      listsAsDuplicateKeys = true;
      mkKeyValue = lib.generators.mkKeyValueDefault { inherit mkValueString; } " ";
    }
    settings);

  redis-settings = {
    port = 0; # do not listen on TCP socket
    daemonize = false;
    loglevel = "notice";
    logfile = "stdout";
    databases = 16;
    maxclients = 10000;
    save = [ "900 1" "300 10" "60 10000" ];
    dbfilename = "dump.rdb";
    dir = "${config.xdg.dataHome}/redis-paperless";
    appendonly = false;
    appendfsync = "everysec";
    slowlog-log-slower-than = 10000;
    slowlog-max-len = 128;
    unixsocket = "${config.xdg.dataHome}/redis-paperless/redis.sock";
  };

in
{
  launchd.agents = {
    paperless-consumer = {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkg}/bin/paperless-ngx document_consumer"
        ];
        RunAtLoad = true;
        EnvironmentVariables = env;
      };
    };

    paperless-web = {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkg.python.pkgs.gunicorn}/bin/gunicorn"
          "-c"
          "${pkg}/lib/paperless-ngx/gunicorn.conf.py"
          "paperless.asgi:application"
        ];
        RunAtLoad = true;
        EnvironmentVariables = env // {
          PATH = pkg.path;
          PYTHONPATH = "${pkg.python.pkgs.makePythonPath pkg.propagatedBuildInputs}:${pkg}/lib/paperless-ngx/src";
        };
      };
    };

    paperless-scheduler = {
      enable = true;
      config = {
        ProgramArguments = [
          (toString (pkgs.writeShellScript "paperless-scheduler" ''
            set -e
            mkdir -p "$PAPERLESS_CONSUMPTION_DIR"
            mkdir -p "$PAPERLESS_MEDIA_ROOT"
            ${pkg}/bin/paperless-ngx migrate
            ${pkg}/bin/paperless-ngx qcluster
          ''))
        ];
        RunAtLoad = true;
        EnvironmentVariables = env;
      };
    };

    redis-paperless = {
      enable = true;
      config = {
        ProgramArguments = [
          (toString (pkgs.writeShellScript "redis-paperless" ''
            set -e
            mkdir -p "${redis-settings.dir}"
            install -m 600 ${redisConfig redis-settings} "${redis-settings.dir}/redis.conf"
            ${pkgs.redis}/bin/redis-server "${redis-settings.dir}/redis.conf"
          ''))
        ];
        RunAtLoad = true;
      };
    };
  };

  home.packages = [
    (mkWrapperDrv {
      original = "${pkg}/bin/paperless-ngx";
      name = "paperless-ngx";
      set = env;
    })
    pkgs.redis
  ];
}
