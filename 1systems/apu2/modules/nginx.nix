{ config, ... }:

{
  services.nginx = {
    enable = true;
    serverNamesHashBucketSize = 128;

    commonHttpConfig = ''
      charset UTF-8;
      port_in_redirect off;
    '';

    virtualHosts = {
      "192.168.168.41" = {
        listen = [
          {
            addr = "192.168.168.41";
            port = 8123;
          }
          {
            addr = "191.18.19.34";
            port = 8123;
          }
          {
            addr = "100.121.61.124";
            port = 8123;
          }
        ];

        locations =
          let
            dlrgProxyCfg = ''
              proxy_pass https://www.dlrg.cloud:443;
            '';
          in
          {

            # proxy hass traffic
            # hass is configured to listen on 127.0.0.1:8123
            "/" = {
              extraConfig = ''
                proxy_pass http://127.0.0.1:8123;
              '';
            };
            "/api/websocket" = {
              extraConfig = ''
                proxy_pass http://127.0.0.1:8123;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "Upgrade";
                proxy_set_header Host $host;
              '';
            };

            # proxy DLRG cloud to work around CSP iframe restrictions 
            # for calendar embedding
            "/apps" = {
              extraConfig = dlrgProxyCfg;
            };
            "/css" = {
              extraConfig = dlrgProxyCfg;
            };
            "/core" = {
              extraConfig = dlrgProxyCfg;
            };
            "/js" = {
              extraConfig = dlrgProxyCfg;
            };
            "/remote.php" = {
              extraConfig = dlrgProxyCfg;
            };
          };
      };
    };
  };

  ptsd.nwlogrotate.config = ''
    /var/log/nginx/access.log {
      daily
      rotate 7
      missingok
      notifempty
      compress
      dateext
      dateformat .%Y-%m-%d
      postrotate
        systemctl kill -s USR1 nginx.service
      endscript
    }
  '';
}
