{ config, lib, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    package = pkgs.postgresql_11;
    extraConfig = ''
      ssl = on
      ssl_cert_file = '/var/lib/lego/certificates-root/${config.networking.hostName}.${config.networking.domain}.crt'
      ssl_key_file = '/var/lib/lego/certificates-root/${config.networking.hostName}.${config.networking.domain}.key'

      # only available starting from postgresql_12
      # ssl_min_protocol_version = TLSv1.3

      password_encryption = scram-sha-256
    '';

    # pg_hba.conf
    authentication = ''
      local all all trust
      hostssl all +scram_sha_256_users 0.0.0.0/0 scram-sha-256
    '';
  };
}
