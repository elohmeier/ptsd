{ config, lib, pkgs, ... }:
let
  domain = "git.nerdworks.de";
  stateDir = "/var/lib/gitea";
  pyenv = pkgs.python3.withPackages (
    pythonPackages: with pythonPackages; [
      jupyter
    ]
  );
in
{
  # git user is required for the openssh integration using "git@..." clone url
  users.users.git = {
    description = "Gitea Service";
    home = stateDir;
    createHome = true;
    useDefaultShell = true; # this is required (if false "nologin" will block access to Gitea/ssh)
    isSystemUser = true;
  };

  services.gitea = {
    enable = true;
    appName = "NerdGit";
    domain = domain;
    stateDir = stateDir;
    cookieSecure = true;
    rootUrl = "https://${domain}/";
    log = { level = "Warn"; };
    httpAddress = "127.0.0.1";
    httpPort = config.ptsd.nwtraefik.ports.nwgit;
    disableRegistration = true;
    user = "git";
    database.user = "git";

    settings = {
      server.SSH_DOMAIN = domain;

      ui = {
        DEFAULT_THEME = "gitea";
        THEMES = "gitea,arc-green";
      };

      api.ENABLE_SWAGGER = false;

      i18n = {
        LANGS = "en-US,de-DE";
        NAMES = "English,Deutsch";
      };

      other = {
        SHOW_FOOTER_VERSION = false;
        SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
      };

      "markup.jupyter" = {
        ENABLED = true;
        FILE_EXTENSIONS = ".ipynb";
        RENDER_COMMAND = "${pyenv}/bin/jupyter nbconvert --stdout --to html --template basic";
        IS_INPUT_FILE = true;
      };
    };
  };

  ptsd.nwtraefik.services = [
    {
      name = "nwgit";
      rule = "Host(`${domain}`)";
      entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
    }
  ];

}
