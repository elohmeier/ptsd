{ config, lib, pkgs, ... }:
let
  domain = "wiki.services.nerdworks.de";
in
{
  ptsd.nwtraefik.services = [
    {
      name = "dokuwiki";
      rule = "Host(`${domain}`)";
    }
  ];

  ptsd.secrets.files."dokuwiki.users" = {
    owner = "dokuwiki";
  };
  users.groups.keys.members = [ "dokuwiki" ];

  services.dokuwiki.nwwiki = {
    enable = true;
    hostName = domain;
    nginx = {
      enableACME = false;
      forceSSL = false;
      listen = [
        {
          addr = "127.0.0.1";
          port = config.ptsd.nwtraefik.ports.dokuwiki;
        }
      ];
    };
    aclUse = true;
    acl = ''
      * @ALL 0
    '';
    usersFile = "/run/keys/dokuwiki.users";
    superUser = "@staff";
    pluginsConfig = ''
      $plugins['authad'] = 0;
      $plugins['authldap'] = 0;
      $plugins['authmysql'] = 0;
      $plugins['authpgsql'] = 0;

      $plugins['dw2pdf'] = 1;
      $plugins['nspages'] = 1;
    '';
    plugins = with pkgs; [
      dokuwiki-plugin-dw2pdf
      dokuwiki-plugin-nspages
      dokuwiki-plugin-pagebreak
    ];
  };
}
