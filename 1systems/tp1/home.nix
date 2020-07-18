let
  common = import ./home-common.nix;
in
{
  dark = { lib, ... }: (
    lib.recursiveUpdate
      {
        ptsd.urxvt.theme = "solarized_dark";
      }
      common
  );

  light = { lib, ... }: (
    lib.recursiveUpdate
      {
        ptsd.urxvt.theme = "solarized_light";
      }
      common
  );
}
