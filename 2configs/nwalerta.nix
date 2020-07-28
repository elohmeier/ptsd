{ config, lib, pkgs, ... }:

{
  ptsd.alerta = {
    enable = true;
    databaseUrl = "postgresql:///alerta";
  };

  services.postgresql.ensureDatabases = [ "alerta" ];
  services.postgresql.ensureUsers = [
    {
      name = "alerta";
      ensurePermissions."DATABASE alerta" = "ALL PRIVILEGES";
    }
  ];

  networking.firewall.allowedTCPPorts = [ 5000 ];
}
