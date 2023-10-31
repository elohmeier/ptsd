{ lib, ... }:

let
  universe = import ../../../../common/universe.nix;
in
{
  services.syncthing = {
    enable = true;

    key = "/var/src/secrets/syncthing.key";
    cert = "/var/src/secrets/syncthing.crt";
    devices = lib.mapAttrs (_: hostcfg: hostcfg.syncthing) (lib.filterAttrs (_: lib.hasAttr "syncthing") universe.hosts);
    folders = {
      "/var/sync/enno/Scans" = { label = "enno/Scans"; id = "ezjwj-xgnhe"; devices = [ "mb4" "iph3" ]; };
      "/var/sync/luisa/Scans" = { label = "luisa/Scans"; id = "dnryo-kz7io"; devices = [ "mb4" "mb3" ]; };
      "/var/sync/laiyer/Scans" = { label = "laiyer/Scans"; id = "nwx3z-7w27q"; devices = [ "mb4" ]; };
    };

    openDefaultPorts = true;
  };

  services.samba = {
    enable = true;
    enableNmbd = false;
    enableWinbindd = false;
    extraConfig = ''
      hosts allow = 100.0.0.0/8
      hosts deny = 0.0.0.0/0
      load printers = no
      local master = no
      max smbd processes = 5
      valid users = syncthing
    '';

    shares =
      let
        defaults = {
          "force group" = "syncthing";
          "force user" = "syncthing";
          "guest ok" = "no";
          "read only" = "no";
          browseable = "no";
        };
      in
      {
        scans-enno = defaults // { path = "/var/sync/enno/Scans"; };
        scans-luisa = defaults // { path = "/var/sync/luisa/Scans"; };
        scans-laiyer = defaults // { path = "/var/sync/laiyer/Scans"; };
      };
  };

  # users.users = {
  #   enno = {
  #     createHome = false;
  #     group = "syncthing";
  #     home = "/var/sync/enno";
  #     isNormalUser = true;
  #     openssh.authorizedKeys.keys = [ "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFLG9ccoKuDGnSPw3R5+Fg1URSjexs7nB6H/hn+Wu9GnT0KcVNYogJcYxQZ4OkPxhv/gyWvwvCRlIlJCL+MFO4g= ShellFish@iph3-05012022" ];
  #     uid = 1000;
  #   };
  #   luisa = {
  #     createHome = false;
  #     group = "syncthing";
  #     home = "/var/sync/luisa";
  #     isNormalUser = true;
  #     openssh.authorizedKeys.keys = [ "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBNSJbK3FwJJYgFA2EsXpgHbMEIaOAbggL3YMixi4vVIG0dmBJxKdg9aOEdm2N5k0htM3cxRWXfiv353WMzLgAQ= ShellFish@nw33-12092022" ];
  #     uid = 1001;
  #   };
  # };
}
