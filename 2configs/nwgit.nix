{ config, lib, pkgs, ... }:
let
  domain = "git.nerdworks.de";
  stateDir = "/var/lib/gitea";
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

  ptsd.gitea = {
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

    extraConfig = ''
      [server]
      SSH_DOMAIN = ${domain}

      [ui]
      DEFAULT_THEME = gitea
      THEMES = gitea,arc-green

      [api]
      ENABLE_SWAGGER = false

      [i18n]
      LANGS = en-US,de-DE
      NAMES = English,Deutsch

      [other]
      SHOW_FOOTER_VERSION = false
      SHOW_FOOTER_TEMPLATE_LOAD_TIME = false
    '';
  };

  ptsd.lego.extraDomains = [
    domain
  ];

  ptsd.nwtraefik.services = [
    {
      name = "nwgit";
      rule = "Host:${domain}";
    }
  ];

  ptsd.nwtelegraf.inputs = {
    http_response = [
      {
        urls = [ "http://${domain}" ];
      }
      {
        urls = [ "https://${domain}" ];
        response_string_match = "Gitea - Git with a cup of tea";
      }
    ];
    x509_cert = [
      {
        sources = [
          "https://${domain}"
        ];
      }
    ];
  };

  ptsd.nwmonit.extraConfig = [
    ''
      check host ${domain} with address ${domain}
        if failed
          port 80
          protocol http
          status = 302
        then alert

        if failed
          port 443
          protocol https and certificate valid > 30 days
          content = "Gitea - Git with a cup of tea"
        then alert
    ''
  ];
}
