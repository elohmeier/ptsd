{ config, lib, pkgs, ... }:

{
  services.openssh.hostKeys = [
    { type = "ed25519"; path = "/nix/secrets/ssh.id_ed25519"; }
  ];

  system.activationScripts.initialize-persistent = lib.stringAfter [ "users" "groups" ] ''
    ${lib.optionalString config.networking.wireless.iwd.enable "mkdir -p /nix/persistent/var/lib/iwd"}
    ${lib.optionalString config.services.octoprint.enable "mkdir -p /nix/persistent/var/lib/octoprint"}
    ${lib.optionalString config.services.samba.enable "mkdir -p /nix/persistent/var/lib/samba"}
    ${lib.optionalString config.services.tailscale.enable "mkdir -p /nix/persistent/var/lib/tailscale"}
    mkdir -p /nix/secrets
    mkdir -p /nix/persistent/var/lib/systemd
    ${pkgs.systemd}/bin/systemd-machine-id-setup --root /nix/persistent
  '';

  fileSystems = {
    "/etc/machine-id" = { device = "/nix/persistent/etc/machine-id"; options = [ "bind" ]; };
    "/var/lib/systemd" = { device = "/nix/persistent/var/lib/systemd"; options = [ "bind" ]; };
  } // lib.optionalAttrs config.networking.wireless.iwd.enable {
    "/var/lib/iwd" = { device = "/nix/persistent/var/lib/iwd"; options = [ "bind" ]; };
  } // lib.optionalAttrs config.services.tailscale.enable {
    "/var/lib/tailscale" = { device = "/nix/persistent/var/lib/tailscale"; options = [ "bind" ]; };
  } // lib.optionalAttrs (config.services.borgbackup.jobs != { }) {
    "/var/cache/borg" = { device = "/nix/persistent/var/cache/borg"; options = [ "bind" ]; };
  };

  systemd.mounts = (lib.optional config.services.samba.enable {
    what = "/nix/persistent/var/lib/samba";
    where = "/var/lib/samba";
    type = "none";
    options = "bind";
    before = [ "samba-nmbd.service" "samba-smbd.service" "samba-winbindd.service" ];
    requiredBy = [ "samba-nmbd.service" "samba-smbd.service" "samba-winbindd.service" ];
  }) ++ (lib.optional config.services.octoprint.enable {
    what = "/nix/persistent/var/lib/octoprint";
    where = "/var/lib/octoprint";
    type = "none";
    options = "bind";
    before = [ "octoprint.service" ];
    requiredBy = [ "octoprint.service" ];
  });

  users.users.root.passwordFile = "/nix/secrets/root.passwd";
}
