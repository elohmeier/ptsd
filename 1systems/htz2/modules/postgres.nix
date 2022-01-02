{ config, lib, pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
    initialScript = pkgs.writeText "synapse-init.sql" ''
      CREATE DATABASE "synapse"
        ENCODING "UTF-8"
        LC_COLLATE = "C"
        LC_CTYPE = "C"
        TEMPLATE template0;
    '';
    ensureUsers = [
      {
        name = "matrix-synapse"; # must match service user
        ensurePermissions."DATABASE synapse" = "ALL PRIVILEGES";
      }
      {
        name = "root";
        ensurePermissions."ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
      }
    ];
  };
}
