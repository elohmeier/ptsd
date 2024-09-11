{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  home.sessionVariables = {
    PASSWORD_STORE_DIR = "${config.home.homeDirectory}/repos/password-store";
    # PASSAGE_DIR = "${config.home.homeDirectory}/repos/passage-store";
  };

  home.file.".password-store".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/password-store";
  # home.file.".passage".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/passage-store";

  home.packages = with pkgs; [
    pass
    # passage
  ];
}
