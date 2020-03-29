{ config, ... }:

{
  ptsd.secrets.files."home-secrets.nix" = {
    source-path = toString <client-secrets> + "/home-secrets.nix";
    owner = config.users.users.mainUser.name;
    group-name = "root";
    mode = "0400";
  };
}
