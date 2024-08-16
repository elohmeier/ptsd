{ pkgs, ... }:

{
  services.prometheus = {
    exporters.blackbox = {
      enable = true;
      listenAddress = "127.0.0.1";
      configFile = pkgs.writeText "blackbox.json" (
        builtins.toJSON {
          modules = {
            http_2xx = {
              prober = "http";
              timeout = "2s";
              http = {
                fail_if_not_ssl = true;
              };
            };

            http_fraam_www = {
              prober = "http";
              timeout = "2s";
              http = {
                fail_if_not_ssl = true;
                fail_if_body_not_matches_regexp = [ "Ihr Projekterfolg." ];
              };
            };

            http_nerdworks_www = {
              prober = "http";
              timeout = "2s";
              http = {
                fail_if_not_ssl = true;
                fail_if_body_not_matches_regexp = [ "Nerdworks Hamburg unterstützt Unternehmen bei." ];
              };
            };

            http_grafana = {
              prober = "http";
              timeout = "2s";
              http = {
                fail_if_not_ssl = true;
                fail_if_body_not_matches_regexp = [ "Grafana" ];
              };
            };

            http_home_assistant = {
              prober = "http";
              timeout = "2s";
              http = {
                fail_if_not_ssl = true;
                fail_if_body_not_matches_regexp = [ "Home Assistant" ];
              };
            };

            http_monica = {
              prober = "http";
              timeout = "2s";
              http = {
                fail_if_not_ssl = true;
                fail_if_body_not_matches_regexp = [ "Monica – personal relationship manager" ];
              };
            };

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
        }
      );
    };
  };

}
