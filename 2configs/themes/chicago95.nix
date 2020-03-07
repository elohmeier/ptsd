{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.chicago95 ];

  fonts.fonts = [ pkgs.chicago95 ];

  programs.bash.promptInit = ''
    source ${pkgs.chicago95}/share/DOSrc
  '';

  users.defaultUserShell = lib.mkForce pkgs.bash;

  #boot.plymouth = {
  #  theme = "Chicago95";
  #  themePackages = [ pkgs.chicago95 ];
  #};
}
