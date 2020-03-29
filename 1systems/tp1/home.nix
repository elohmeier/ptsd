let
  unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
  };

  common = {
    imports = [
      <ptsd/2configs/home>
      <ptsd/2configs/home/baseX.nix>
      <ptsd/2configs/home/extraTools.nix>
      <ptsd/2configs/home/xsession-i3.nix>
    ];

    ptsd.i3.fontSize = 12;
    ptsd.urxvt.fontSize = 12;

    home.packages = [ unstable.steam ];
  };
in
{
  dark = { lib, ... }: (
    lib.recursiveUpdate {
      ptsd.urxvt.theme = "solarized_dark";
    } common
  );

  light = { lib, ... }: (
    lib.recursiveUpdate {
      ptsd.urxvt.theme = "solarized_light";
    } common
  );
}
