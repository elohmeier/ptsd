{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ptsd;
in
{
  options.ptsd = {
    bootstrap = mkOption {
      type = types.bool;
      default = false;
      description = "remove all unnecessary stuff which is unneeded for booting and basic connectivity";
    };

    minimal = mkOption {
      type = types.bool;
      default = cfg.bootstrap;
      description = "disable most packages to reduce the closure size, but include e.g. basic desktop functionality";
    };
  };

  config = mkMerge [
    (mkIf cfg.minimal {

      documentation = {
        enable = false;
        man.enable = false;
        info.enable = false;
        doc.enable = false;
        dev.enable = false;
      };

      services.gvfs.enable = false;

      virtualisation = {
        docker.enable = false;
        libvirtd.enable = false;
        spiceUSBRedirection.enable = false;
      };

      services.blueman.enable = false;
      services.udisks2.enable = false;
      security.polkit.enable = false;
      services.postgresql.enable = mkForce false;

      services.samba.enable = false;
      services.fail2ban.enable = false;
      services.gnome.gnome-keyring.enable = false;
      #environment.noXlibs = true;
      programs.fish.enable = mkForce false;
      users.defaultUserShell = mkForce pkgs.bash;
    })

    (mkIf cfg.bootstrap {
      hardware.opengl.enable = mkForce false;
      networking.networkmanager.enable = mkForce false;
      environment.defaultPackages = [ ];
    })

  ];

}
