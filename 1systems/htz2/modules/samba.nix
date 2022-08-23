{ config, lib, pkgs, ... }:

let
  defaults = {
    "force group" = "syncthing";
    "force user" = "syncthing";
    "guest ok" = "no";
    "read only" = "no";
    browseable = "no";
  };
  universe = import ../../../2configs/universe.nix;
in
{
  services.samba = {
    enable = true;
    enableNmbd = false;
    enableWinbindd = false;
    extraConfig = ''
      hosts allow = 95.112.0.0/13 # AS6805
      hosts deny = 0.0.0.0/0
      load printers = no
      local master = no
      max smbd processes = 5
      server min protocol = SMB3_11
      server smb encrypt = required
      server smb3 encryption algorithms = -AES-128-GCM -AES-128-CCM
      valid users = syncthing
    '';

    shares = {
      "ipc$"."hosts deny" = "0.0.0.0/0";
      scans-enno = defaults // { path = "/var/lib/syncthing/enno/Scans"; };
      scans-luisa = defaults // { path = "/var/lib/syncthing/luisa/Scans"; };
    };
  };

  services.syncthing = {
    enable = true;

    key = "/var/src/secrets/syncthing.key";
    cert = "/var/src/secrets/syncthing.crt";
    devices = lib.mapAttrs (_: hostcfg: hostcfg.syncthing) (lib.filterAttrs (_: hostcfg: lib.hasAttr "syncthing" hostcfg) universe.hosts);
    folders = {
      "/var/lib/syncthing/enno/Scans" = { label = "enno/Scans"; id = "ezjwj-xgnhe"; devices = [ "mb4" "iph3" ]; };
      "/var/lib/syncthing/luisa/Scans" = { label = "luisa/Scans"; id = "dnryo-kz7io"; devices = [ "mb4" "mb1" "mb3" ]; };
    };
  };

  networking.firewall.allowedTCPPorts = [ 445 ];

  #networking.firewall = {
  #  extraCommands = ''
  #    iptables -A nixos-fw -p tcp --source 95.112.0.0/13 --dport 445:445 -j nixos-fw-accept
  #  '';
  #  extraStopCommands = ''
  #    iptables -D nixos-fw -p tcp --source 95.112.0.0/13 --dport 445:445 -j nixos-fw-accept || true
  #  '';
  #};
}
