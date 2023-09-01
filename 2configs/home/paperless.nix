{ config, lib, pkgs, ... }:

let
  pkg = pkgs.paperless-ngx;
  dataDir = "${config.xdg.dataHome}/paperless";
  nltkDir = "${config.xdg.dataHome}/paperless/nltk";

  env = {
    PAPERLESS_DATA_DIR = dataDir;
    # PAPERLESS_CONSUMPTION_DIR = "${dataDir}/consume";
    PAPERLESS_CONSUMPTION_DIR = "/Users/enno/Sync/Scans-Enno";
    PAPERLESS_MEDIA_ROOT = "${dataDir}/media";
    PAPERLESS_REDIS = "unix://${config.xdg.dataHome}/redis-paperless/redis.sock";
    PAPERLESS_NLTK_DIR = nltkDir;
    GUNICORN_CMD_ARGS = "--bind=127.0.0.1:9876 --worker-tmp-dir=/tmp";
    PAPERLESS_CONSUMER_POLLING = "30"; # seconds
  };

  # utility function around makeWrapper
  mkWrapperDrv = { original, name, set ? { } }:
    pkgs.runCommand "${name}-wrapper" { nativeBuildInputs = [ pkgs.makeWrapper ]; } (with lib; ''
      makeWrapper "${original}" "$out/bin/${name}" \
        ${concatStringsSep " \\\n " (mapAttrsToList (name: value: ''--set ${name} "${value}"'') set)}
    '');

  redisConfig = settings: pkgs.writeText "redis.conf" (lib.generators.toKeyValue
    {
      listsAsDuplicateKeys = true;
      mkKeyValue = lib.generators.mkKeyValueDefault { } " ";
    }
    settings);

  redis-settings = {
    port = 0; # do not listen on TCP socket
    daemonize = "no";
    loglevel = "notice";
    logfile = ''""''; # log to stdout
    databases = 16;
    maxclients = 10000;
    save = [ "900 1" "300 10" "60 10000" ];
    dbfilename = "dump.rdb";
    dir = "${config.xdg.dataHome}/redis-paperless";
    appendonly = "no";
    appendfsync = "everysec";
    slowlog-log-slower-than = 10000;
    slowlog-max-len = 128;
    unixsocket = "${config.xdg.dataHome}/redis-paperless/redis.sock";
  };

  redis-paperless = pkgs.writeShellScriptBin "redis-paperless" ''
    set -e
    mkdir -p "${redis-settings.dir}"
    install -m 600 ${redisConfig redis-settings} "${redis-settings.dir}/redis.conf"
    ${pkgs.redis}/bin/redis-server "${redis-settings.dir}/redis.conf"
  '';

  paperless-web =
    let
      pythonWithNltk = pkg.python.withPackages (ps: [ ps.nltk ]);
    in
    pkgs.writeShellScriptBin "paperless-web" ''
      ${pythonWithNltk}/bin/python -m nltk.downloader -d '${nltkDir}' punkt snowball_data stopwords

      export PAPERLESS_DATA_DIR="${env.PAPERLESS_DATA_DIR}"
      export PAPERLESS_CONSUMPTION_DIR="${env.PAPERLESS_CONSUMPTION_DIR}"
      export PAPERLESS_MEDIA_ROOT="${env.PAPERLESS_MEDIA_ROOT}"
      export PAPERLESS_REDIS="${env.PAPERLESS_REDIS}"
      export PAPERLESS_NLTK_DIR="${env.PAPERLESS_NLTK_DIR}"
      export PAPERLESS_CONSUMER_POLLING="${env.PAPERLESS_CONSUMER_POLLING}"
      export GUNICORN_CMD_ARGS="${env.GUNICORN_CMD_ARGS}"
      export PATH="${pkg.path}"
      export PYTHONPATH="${pkg.python.pkgs.makePythonPath pkg.propagatedBuildInputs}:${pkg}/lib/paperless-ngx/src"
      ${pkg.python.pkgs.gunicorn}/bin/gunicorn \
        -c "${pkg}/lib/paperless-ngx/gunicorn.conf.py" \
        "paperless.asgi:application"
    '';

  paperless-scheduler = pkgs.writeShellScriptBin "paperless-scheduler" ''
    set -e
    export PAPERLESS_DATA_DIR="${env.PAPERLESS_DATA_DIR}"
    export PAPERLESS_CONSUMPTION_DIR="${env.PAPERLESS_CONSUMPTION_DIR}"
    export PAPERLESS_MEDIA_ROOT="${env.PAPERLESS_MEDIA_ROOT}"
    export PAPERLESS_REDIS="${env.PAPERLESS_REDIS}"
    export PAPERLESS_NLTK_DIR="${env.PAPERLESS_NLTK_DIR}"
    export PAPERLESS_CONSUMER_POLLING="${env.PAPERLESS_CONSUMER_POLLING}"
    mkdir -p "$PAPERLESS_CONSUMPTION_DIR"
    mkdir -p "$PAPERLESS_MEDIA_ROOT"
    ${pkg}/bin/paperless-ngx migrate
    ${pkg}/bin/celery --app paperless beat --loglevel INFO
  '';

  paperless-task-queue = pkgs.writeShellScriptBin "paperless-task-queue" ''
    set -e
    export PAPERLESS_DATA_DIR="${env.PAPERLESS_DATA_DIR}"
    export PAPERLESS_CONSUMPTION_DIR="${env.PAPERLESS_CONSUMPTION_DIR}"
    export PAPERLESS_MEDIA_ROOT="${env.PAPERLESS_MEDIA_ROOT}"
    export PAPERLESS_REDIS="${env.PAPERLESS_REDIS}"
    export PAPERLESS_NLTK_DIR="${env.PAPERLESS_NLTK_DIR}"
    export PAPERLESS_CONSUMER_POLLING="${env.PAPERLESS_CONSUMER_POLLING}"
    mkdir -p "$PAPERLESS_CONSUMPTION_DIR"
    mkdir -p "$PAPERLESS_MEDIA_ROOT"
    ${pkg}/bin/celery --app paperless worker --loglevel INFO
  '';

  paperless-consumer = pkgs.writeShellScriptBin "paperless-consumer" ''
    set -e
    export PAPERLESS_DATA_DIR="${env.PAPERLESS_DATA_DIR}"
    export PAPERLESS_CONSUMPTION_DIR="${env.PAPERLESS_CONSUMPTION_DIR}"
    export PAPERLESS_MEDIA_ROOT="${env.PAPERLESS_MEDIA_ROOT}"
    export PAPERLESS_REDIS="${env.PAPERLESS_REDIS}"
    export PAPERLESS_NLTK_DIR="${env.PAPERLESS_NLTK_DIR}"
    export PAPERLESS_CONSUMER_POLLING="${env.PAPERLESS_CONSUMER_POLLING}"
    mkdir -p "$PAPERLESS_CONSUMPTION_DIR"
    mkdir -p "$PAPERLESS_MEDIA_ROOT"
    ${pkg}/bin/paperless-ngx document_consumer
  '';
in
{
  launchd.agents = {
    paperless-consumer = {
      enable = true;
      config = {
        ProgramArguments = [ "${paperless-consumer}/bin/paperless-consumer" ];
        RunAtLoad = true;
        StandardOutPath = "${config.xdg.dataHome}/paperless/paperless-consumer.out";
        StandardErrorPath = "${config.xdg.dataHome}/paperless/paperless-consumer.err";
      };
    };

    paperless-web = {
      enable = true;
      config = {
        ProgramArguments = [ "${paperless-web}/bin/paperless-web" ];
        RunAtLoad = true;
        StandardOutPath = "${config.xdg.dataHome}/paperless/paperless-web.out";
        StandardErrorPath = "${config.xdg.dataHome}/paperless/paperless-web.err";
      };
    };

    paperless-scheduler = {
      enable = true;
      config = {
        ProgramArguments = [ "${paperless-scheduler}/bin/paperless-scheduler" ];
        RunAtLoad = true;
        StandardOutPath = "${config.xdg.dataHome}/paperless/paperless-scheduler.out";
        StandardErrorPath = "${config.xdg.dataHome}/paperless/paperless-scheduler.err";
      };
    };

    paperless-task-queue = {
      enable = true;
      config = {
        ProgramArguments = [ "${paperless-task-queue}/bin/paperless-task-queue" ];
        RunAtLoad = true;
        StandardOutPath = "${config.xdg.dataHome}/paperless/paperless-task-queue.out";
        StandardErrorPath = "${config.xdg.dataHome}/paperless/paperless-task-queue.err";
      };
    };

    redis-paperless = {
      enable = true;
      config = {
        ProgramArguments = [ "${redis-paperless}/bin/redis-paperless" ];
        RunAtLoad = true;
        StandardOutPath = "${config.xdg.dataHome}/paperless/redis-paperless.out";
        StandardErrorPath = "${config.xdg.dataHome}/paperless/redis-paperless.err";
      };
    };
  };

  home.packages = [
    (mkWrapperDrv {
      original = "${pkg}/bin/paperless-ngx";
      name = "paperless-ngx";
      set = env;
    })
    (mkWrapperDrv {
      original = "${pkg}/bin/celery";
      name = "paperless-ngx-celery";
      set = env;
    })
    pkgs.redis
    redis-paperless
    paperless-consumer
    paperless-scheduler
    paperless-task-queue
    paperless-web
  ];
}
