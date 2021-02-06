{ config, lib, pkgs, ... }:
{
  ptsd.secrets.files.awscli-credentials = {
    owner = config.users.users.mainUser.name;
    source-path = toString <secrets/awscli-credentials>;
    group-name = "root";
    mode = "0400";
  };

  home-manager =
    {
      users.mainUser = { config, pkgs, nixosConfig, ... }:
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
            ".aws/credentials".source = config.lib.file.mkOutOfStoreSymlink nixosConfig.ptsd.secrets.files."awscli-credentials".path;
          };
        };
    };
}
