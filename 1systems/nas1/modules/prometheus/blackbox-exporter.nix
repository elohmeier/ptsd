{ config, lib, pkgs, ... }:

{
  services.prometheus = {
    exporters.blackbox = {
      enable = true;
      listenAddress = "127.0.0.1";
      configFile = pkgs.writeText "blackbox.json" (builtins.toJSON {
        modules = {
          http_2xx = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
            };
          };

          http_acme_dns = {
            prober = "http";
            timeout = "2s";
            http = {
              valid_status_codes = [ 405 ];
              fail_if_not_ssl = true;
            };
          };

          http_fraam_www = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
              fail_if_body_not_matches_regexp = [
                "Ihr Projekterfolg."
              ];
            };
          };

          http_nextcloud = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
              fail_if_body_not_matches_regexp = [
                "a safe home for all your data"
              ];
            };
          };

          http_gitea = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
              fail_if_body_not_matches_regexp = [
                "Gitea - Git with a cup of tea"
              ];
            };
          };

          http_nerdworks_www = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
              fail_if_body_not_matches_regexp = [
                "Nerdworks Hamburg unterstützt Unternehmen bei."
              ];
            };
          };


          http_grafana = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
              fail_if_body_not_matches_regexp = [
                "Grafana"
              ];
            };
          };

          http_home_assistant_bs53 = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
              fail_if_body_not_matches_regexp = [
                "Home Assistant"
              ];
            };
          };

          http_home_assistant_dlrg = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = false;
              fail_if_body_not_matches_regexp = [
                "Home Assistant"
              ];
            };
          };

          http_monica = {
            prober = "http";
            timeout = "2s";
            http = {
              fail_if_not_ssl = true;
              fail_if_body_not_matches_regexp = [
                "Monica – personal relationship manager"
              ];
            };
          };

          # http_drone = {
          #   prober = "http";
          #   timeout = "2s";
          #   http = {
          #     fail_if_not_ssl = true;
          #     fail_if_body_not_matches_regexp = [
          #       "Drone"
          #     ];
          #   };
          # };

          http_gitlab = {
            prober = "http";
            timeout = "2s";
            http = {
              method = "HEAD";
              fail_if_not_ssl = true;
              valid_status_codes = [ 302 ];
              no_follow_redirects = true;
              fail_if_header_not_matches = [
                {
                  header = "Location";
                  regexp = "https://.+/users/sign_in";
                }
              ];
            };
          };
        };
      });
    };
  };

}
