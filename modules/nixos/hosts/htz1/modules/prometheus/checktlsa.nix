{ pkgs, ... }:

{
  systemd.services.prometheus-checktlsa = {
    description = "monitor ssl/tlsa/dane for nerdworks.de mail";
    environment = {
      # use google dns for TLSA lookup
      HOME = pkgs.writeTextFile {
        name = "digrc";
        text = "@8.8.8.8";
        destination = "/.digrc";
      };
    };
    path = with pkgs; [
      moreutils
      prom-checktlsa
    ];
    script = ''
      prom-checktlsa | sponge /var/log/prometheus-check_ssl_cert.prom
    '';
    startAt = "*:0/15"; # every 15 mins
  };
}
