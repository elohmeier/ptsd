{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ptsd.oauth2-proxy;
in
{
  options.ptsd.oauth2-proxy = {
    enable = mkEnableOption "oauth2-proxy";
    protectedHosts = mkOption {
      type = with types; listOf str;
    };
  };

  config = mkIf cfg.enable {

    systemd.services.oauth2-proxy = {
      description = "OAuth2 Proxy";
      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.oauth2-proxy}/bin/oauth2-proxy --email-domain fraam.de";
        DynamicUser = true;
        Restart = "on-failure";
        EnvironmentFile = "/var/src/secrets/oauth2-proxy.env";
      };
    };

    services.nginx.appendHttpConfig = ''
      proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=auth_cache:10m max_size=100m inactive=60m;
    '';

    services.nginx.virtualHosts = builtins.listToAttrs (map
      (name: {
        inherit name; value.locations = {
        "/oauth2/".extraConfig = ''
          proxy_pass http://127.0.0.1:4180;
        '';

        "/oauth2/auth".extraConfig = ''
          proxy_pass http://127.0.0.1:4180;
          proxy_set_header Content-Length "";
          proxy_pass_request_body off;

          proxy_cache auth_cache;
          proxy_cache_key $host$cookie__oauth2_proxy;
          proxy_cache_valid 202 401 300s;
          proxy_cache_lock on;
        '';


        "/".extraConfig = ''
          auth_request /oauth2/auth;
          error_page 401 = /oauth2/sign_in;
        '';
      };
      })
      cfg.protectedHosts);
  };
}
