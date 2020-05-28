{ config, lib, pkgs, ... }:

let
  domain = "wiki.services.nerdworks.de";
in
{
  ptsd.lego.extraDomains = [
    domain
  ];

  ptsd.nwtraefik.services = [
    {
      name = "dokuwiki";
      rule = "Host:${domain}";
    }
  ];

  nixpkgs = {
    config.packageOverrides = pkgs: {
      dokuwiki = pkgs.symlinkJoin {
        name = "dokuwiki-with-plugins";
        paths = [
          pkgs.dokuwiki
          (pkgs.callPackage <ptsd/5pkgs/dokuwiki-plugin-dw2pdf> {})
        ];
      };
    };
  };

  services.dokuwiki = {
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
    usersFile = <secrets/dokuwiki.users>;
    superUser = "@staff";
  };
}
