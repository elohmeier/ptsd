{ config, lib, pkgs, ... }:

{
  hardware = {
    bluetooth = {
      enable = true;
      package = pkgs.bluezFull;
    };
    pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];
  };

  services.blueman.enable = config.services.xserver.enable;

  # improved version of the pkgs.blueman-provided user service
  systemd.user.services.blueman-applet-nw = lib.mkIf config.services.xserver.enable {
    description = "Bluetooth management applet";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      # Workaround from https://github.com/NixOS/nixpkgs/issues/7329 to make GTK-Themes work
      ExecStart = "${pkgs.bash}/bin/bash -c 'source ${config.system.build.setEnvironment}; exec ${pkgs.blueman}/bin/blueman-applet'";
      RestartSec = 3;
      Restart = "always";
    };
  };
}
