{ pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
  };
in
{
  imports = [
    <ptsd/2configs/home>
    <ptsd/2configs/home/baseX.nix>
    <ptsd/2configs/home/extraTools.nix>
    <ptsd/2configs/home/xsession-i3.nix>
  ];

  ptsd.i3.fontSize = 12;
  ptsd.urxvt.fontSize = 12;

  ptsd.obs = {
    enable = true;
    nvidiaSupport = false;
  };

  home.packages = [ unstable.steam ];

  xsession.initExtra = ''
    # will dim after 10 mins, lock 5 sec after.
    # see xss-lock configuration for details.
    ${pkgs.xorg.xset}/bin/xset s 600 5
  '';
}
