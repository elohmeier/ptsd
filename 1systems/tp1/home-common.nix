{ pkgs, ... }:

{
  imports = [
    <ptsd/2configs/home>
    <ptsd/2configs/home/baseX.nix>
    <ptsd/2configs/home/extraTools.nix>
    <ptsd/2configs/home/xsession-i3.nix>
  ];

  ptsd.i3.fontSize = 12;
  ptsd.urxvt.fontSize = 12;

  home.packages = [ pkgs.steam ];

  xsession.initExtra = ''
    # will dim after 10 mins, lock 5 sec after.
    # see xss-lock configuration for details.
    ${pkgs.xorg.xset}/bin/xset s 600 5
  '';
}
