{ config, lib, pkgs, ... }:

let
  ezaExa = if lib.versionAtLeast config.system.stateVersion "23.11" then pkgs.eza else pkgs.exa;
  ezaExaCmd = if lib.versionAtLeast config.system.stateVersion "23.11" then "${pkgs.eza}/bin/eza" else "${pkgs.exa}/bin/exa";
in
{
  programs.fish = {
    enable = true;
    shellAliases = {
      l = "${ezaExaCmd} -al";
      la = "${ezaExaCmd} -al";
      lg = "${ezaExaCmd} -al --git";
      ll = "${ezaExaCmd} -l";
      ls = "${ezaExaCmd}";
      tree = "${ezaExaCmd} --tree";
    };
  };

  users.defaultUserShell = pkgs.fish;

  environment.systemPackages = [
    ezaExa
  ];
}

