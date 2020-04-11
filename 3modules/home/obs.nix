{ config, lib, pkgs, ... }:

with lib;
let
  unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
    config.packageOverrides = import ../../5pkgs unstable;
  };
  cfg = config.ptsd.obs;
  dag = import <home-manager/modules/lib/dag.nix> { inherit lib; };


  # add nvidia encoder support to OBS
  obs-studio = unstable.obs-studio.overrideAttrs (
    old: lib.optionalAttrs cfg.nvidiaSupport {
      buildInputs = old.buildInputs ++ [
        unstable.linuxPackages_latest.nvidiaPackages.stable
      ];
      postInstall = ''
        wrapProgram $out/bin/obs \
          --prefix "LD_LIBRARY_PATH" : "${unstable.xorg.libX11.out}/lib:${unstable.vlc}/lib:${unstable.linuxPackages_latest.nvidiaPackages.stable}/lib"
      '';
    }
  );

  obs-v4l2sink = unstable.libsForQt5.callPackage ../../5pkgs/obs-v4l2sink { obs-studio = obs-studio; };
in
{
  options.ptsd.obs = {
    enable = mkEnableOption "obs";
    nvidiaSupport = mkEnableOption "nvidia-support";
  };

  config = mkIf cfg.enable {

    home.activation.linkObsPlugins = dag.dagEntryAfter [ "writeBoundary" ] ''
      rm -rf $HOME/.config/obs-studio/plugins
      mkdir -p $HOME/.config/obs-studio/plugins
      ln -sf ${obs-v4l2sink}/lib/obs-plugins/v4l2sink $HOME/.config/obs-studio/plugins/v4l2sink
    '';

    home.packages = [
      obs-studio
    ];

  };
}
