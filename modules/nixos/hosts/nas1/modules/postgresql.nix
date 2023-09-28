{ config, pkgs, ... }:
let
  certDir = "/var/lib/acme/${config.networking.hostName}.${config.networking.domain}";
in
{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    package = pkgs.postgresql_13;
    settings = {
      ssl = "on";
      ssl_cert_file = "/var/lib/postgresql/cert-postgresql.pem";
      ssl_key_file = "/var/lib/postgresql/key-postgresql.pem";

      # only available starting from postgresql_12
      # ssl_min_protocol_version = "TLSv1.3";

      password_encryption = "scram-sha-256";
    };

    # pg_hba.conf
    authentication = ''
      local all all trust
      hostssl all +scram_sha_256_users 0.0.0.0/0 scram-sha-256
    '';
  };

  systemd.services.postgresql.preStart = ''
    cp "${certDir}/cert.pem" "/var/lib/postgresql/cert-postgresql.pem"
    cp "${certDir}/key.pem" "/var/lib/postgresql/key-postgresql.pem"
    chown postgres:postgres "/var/lib/postgresql/cert-postgresql.pem" "/var/lib/postgresql/key-postgresql.pem"
    chmod 600 "/var/lib/postgresql/cert-postgresql.pem" "/var/lib/postgresql/key-postgresql.pem"
  '';

  users.groups.certs.members = [ "postgres" ];
}
