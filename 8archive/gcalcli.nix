{ config, lib, pkgs, ... }:
{
  ptsd.secrets.files.gcalclirc = {
    owner = config.users.users.mainUser.name;
    source-path = toString <secrets/gcalclirc>;
    group-name = "root";
    mode = "0400";
  };

  home-manager =
    {
      users.mainUser = { config, pkgs, nixosConfig, ... }:
        {
          home.packages = [ pkgs.gcalcli ];
          home.file = {
            ".gcalclirc".source = config.lib.file.mkOutOfStoreSymlink nixosConfig.ptsd.secrets.files.gcalclirc.path;
          };
        };
    };
}
