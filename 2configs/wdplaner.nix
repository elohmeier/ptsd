{ config, lib, pkgs, ... }:
{
  imports =
    [
      <ptsd/2configs/postgresql.nix>
    ];

  services.postgresql.ensureDatabases = [ "wdplaner" ];
  services.postgresql.ensureUsers = [
    {
      name = "wdplaner";
      ensurePermissions."DATABASE wdplaner" = "ALL PRIVILEGES";
    }
    {
      # to use your user:
      # 1. login via ssh
      # 2. change password
      #   run `psql wdplaner`
      #   inside psql:
      #     run `alter user USERNAME with password 'XXX';`
      # 3. add user to scram_sha_256_users group (see ./postgresql.nix)
      #   sudo -u postgres -i
      #   run `psql`
      #   inside psql:
      #     run `create role scram_sha_256_users;` (might exist already)
      #     run `grant scram_sha_256_users to USERNAME;`
      name = config.users.users.mainUser.name;
      ensurePermissions."DATABASE wdplaner" = "ALL PRIVILEGES";
    }
  ];

  # see https://docs.hasura.io/1.0/graphql/manual/deployment/postgres-permissions.html

  networking.firewall.interfaces.nwvpn.allowedTCPPorts = [
    5432 # postgresql
  ];

  ptsd.lego.extraDomains = [ "wrd.nerdworks.de" ];
}
