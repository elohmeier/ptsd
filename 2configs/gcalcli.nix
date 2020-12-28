{ config, lib, pkgs, ... }:
{
  ptsd.secrets.files.gcalclirc = {
    owner = config.users.users.mainUser.name;
    source-path = toString <secrets/gcalclirc>;
    group-name = "root";
    mode = "0400";
  };

  home-manager =
    let
      hostConfig = config; in
    {
      users.mainUser = { config, pkgs, ... }:
        {
          home.packages = [ pkgs.gcalcli ];
          home.file = {
            ".gcalclirc".source = config.lib.file.mkOutOfStoreSymlink hostConfig.ptsd.secrets.files.gcalclirc.path;
          };
        };
    };
}
