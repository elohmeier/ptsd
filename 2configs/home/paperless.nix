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
    logfile = ''""''; # log to stdout
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

  redis-paperless = pkgs.writeShellScriptBin "redis-paperless" ''
    set -e
    mkdir -p "${redis-settings.dir}"
    install -m 600 ${redisConfig redis-settings} "${redis-settings.dir}/redis.conf"
    ${pkgs.redis}/bin/redis-server "${redis-settings.dir}/redis.conf"
  '';

  paperless-web = pkgs.writeShellScriptBin "paperless-web" ''
    export PAPERLESS_DATA_DIR="${env.PAPERLESS_DATA_DIR}"
    export PAPERLESS_CONSUMPTION_DIR="${env.PAPERLESS_CONSUMPTION_DIR}"
    export PAPERLESS_MEDIA_ROOT="${env.PAPERLESS_MEDIA_ROOT}"
    export PAPERLESS_REDIS="${env.PAPERLESS_REDIS}"
    export GUNICORN_CMD_ARGS="${env.GUNICORN_CMD_ARGS}"
    export PATH="${pkg.path}"z
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
    mkdir -p "$PAPERLESS_CONSUMPTION_DIR"
    mkdir -p "$PAPERLESS_MEDIA_ROOT"
    ${pkg}/bin/celery --app paperless worker --loglevel INFO
  '';

  nltk-stopwords = pkgs.fetchzip {
    name = "nltk-stopwords";
    url = "https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/corpora/stopwords.zip";
    sha256 = "sha256-tX1CMxSvFjr0nnLxbbycaX/IBnzHFxljMZceX5zElPY=";
  };

  nltk-punkt = pkgs.fetchzip {
    name = "nltk-punkt";
    url = "https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/tokenizers/punkt.zip";
    sha256 = "sha256-SKZu26K17qMUg7iCFZey0GTECUZ+sTTrF/pqeEgJCos=";
  };
in
{
  home.file.".local/share/paperless/nltk/corpora/stopwords".source = nltk-stopwords;
  home.file.".local/share/paperless/nltk/tokenizers/punkt".source = nltk-punkt;

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
        ProgramArguments = [ "${paperless-web}/bin/paperless-web" ];
        RunAtLoad = true;
      };
    };

    paperless-scheduler = {
      enable = true;
      config = {
        ProgramArguments = [ "${paperless-scheduler}/bin/paperless-scheduler" ];
        RunAtLoad = true;
        EnvironmentVariables = env;
      };
    };

    paperless-task-queue = {
      enable = true;
      config = {
        ProgramArguments = [ "${paperless-task-queue}/bin/paperless-task-queue" ];
        RunAtLoad = true;
        EnvironmentVariables = env;
      };
    };

    redis-paperless = {
      enable = true;
      config = {
        ProgramArguments = [ "${redis-paperless}/bin/redis-paperless" ];
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
    (mkWrapperDrv {
      original = "${pkg}/bin/celery";
      name = "paperless-ngx-celery";
      set = env;
    })
    pkgs.redis
    redis-paperless
    paperless-web
    paperless-scheduler
    paperless-task-queue
  ];
}
