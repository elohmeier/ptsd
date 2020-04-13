{ config, pkgs, ... }:
let
  pyenv = pkgs.python3.withPackages (
    pythonPackages: with pythonPackages; [
      black
      jupyterlab
      requests
      selenium
      sqlalchemy
    ]
  );
in
{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "19.09";

  imports = [
    <ptsd/2configs/home/git.nix>
    <ptsd/2configs/home/vim.nix>
    <ptsd/2configs/home/zsh.nix>
  ];

  home.packages = with pkgs; [
    coreutils
    pass
    pyenv
    geckodriver
    nixpkgs-fmt
    lorri
    procps
  ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  home.sessionVariables = {
    EDITOR = "vim";
    PASSWORD_STORE_DIR = "/Users/enno/repos/password-store";
  };
}
