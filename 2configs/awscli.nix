{ config, lib, pkgs, ... }:
{
  ptsd.secrets.files.awscli-credentials = {
    owner = config.users.users.mainUser.name;
    source-path = toString <secrets/awscli-credentials>;
    group-name = "root";
    mode = "0400";
  };

  home-manager =
    let
      hostConfig = config; in
    {
      users.mainUser = { config, pkgs, ... }:
        {
          home.packages = [ pkgs.awscli2 ];
          home.file = {
            ".aws/config".text = lib.generators.toINI
              { }
              {
                "default" = {
                  region = "eu-central-1";
                };
              };
            ".aws/credentials".source = config.lib.file.mkOutOfStoreSymlink hostConfig.ptsd.secrets.files."awscli-credentials".path;
          };
        };
    };
}
