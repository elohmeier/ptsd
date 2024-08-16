{ config, pkgs, ... }:

{
  services.monica = {
    enable = true;
    hostname = "monica"; # nginx vhost name
    appURL = "https://${config.ptsd.tailscale.fqdn}:${toString config.ptsd.ports.monica}";
    appKeyFile = toString (pkgs.writeText "monica-appkey.txt" "dummydummydummydummydummydummydu");
    nginx = {
      forceSSL = true;
      listen = [
        {
          addr = config.ptsd.tailscale.ip;
          port = config.ptsd.ports.monica;
          ssl = true;
        }
      ];
      sslCertificate = "/var/lib/tailscale-cert/${config.ptsd.tailscale.fqdn}.crt";
      sslCertificateKey = "/var/lib/tailscale-cert/${config.ptsd.tailscale.fqdn}.key";
    };
  };

  services.mysqlBackup = {
    enable = true;
    databases = [ "monica" ];
  };
}
