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
          (
            pkgs.dokuwiki.overrideAttrs
              (
                old: rec {
                  # original preload plus DOKU_PLUGIN definition
                  preload = pkgs.writeText "preload.php" ''
                    <?php

                      $config_cascade = array(
                        'acl' => array(
                          'default'   => getenv('DOKUWIKI_ACL_AUTH_CONFIG'),
                        ),
                        'plainauth.users' => array(
                          'default'   => getenv('DOKUWIKI_USERS_AUTH_CONFIG'),
                          'protected' => "" // not used by default
                        ),
                      );
    
                      define('DOKU_PLUGIN', getenv('DOKUWIKI_PLUGINS_DIR'));
                  '';

                  installPhase = ''
                    mkdir -p $out/share/dokuwiki
                    cp -r * $out/share/dokuwiki
                    cp ${preload} $out/share/dokuwiki/inc/preload.php
                    cp ${old.phpLocalConfig} $out/share/dokuwiki/conf/local.php
                    cp ${old.phpPluginsLocalConfig} $out/share/dokuwiki/conf/plugins.local.php
                  '';
                }
              )
          )

          # remember to clear the cache (/var/lib/dokuwiki/data/cache) when modifying plugins
          (pkgs.callPackage <ptsd/5pkgs/dokuwiki-plugin-dw2pdf> {})
          (pkgs.callPackage <ptsd/5pkgs/dokuwiki-plugin-nspages> {})
          (pkgs.callPackage <ptsd/5pkgs/dokuwiki-plugin-pagebreak> {})
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
    pluginsConfig = ''
      $plugins['authad'] = 0;
      $plugins['authldap'] = 0;
      $plugins['authmysql'] = 0;
      $plugins['authpgsql'] = 0;

      $plugins['dw2pdf'] = 1;
      $plugins['nspages'] = 1;
    '';
  };
  services.phpfpm.pools.dokuwiki.phpEnv = {
    DOKUWIKI_PLUGINS_DIR = "${pkgs.dokuwiki}/share/dokuwiki/lib/plugins/";
  };
}
