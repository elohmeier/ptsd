with import <ptsd/lib>;
{ config, pkgs, ... }:

let
  letsgo = pkgs.writeShellScriptBin "letsgo" ''
    set -e
    ${pkgs.cryptsetup}/bin/cryptsetup luksOpen /dev/sda2 srv_crypt
    ${pkgs.utillinux}/bin/mount /dev/mapper/srv_crypt /srv
    ${pkgs.systemd}/bin/systemctl start ftpmail-enno
    ${pkgs.systemd}/bin/systemctl start ftpmail-luisa
    ${pkgs.systemd}/bin/systemctl start gitea
    #${pkgs.systemd}/bin/systemctl start drone
  '';
in
{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost.nix>
    <ptsd/2configs/unbound.nix>
    <secrets-shared/nwsecrets.nix>
  ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "apu1";
    bridges.br0.interfaces = [
      "enp1s0"
      "enp2s0"
      #"enp3s0"
    ];
    interfaces.br0 = {
      useDHCP = true;
    };
  };

  #  ptsd.nwmonit.extraConfig = [
  #    ''
  #      check filesystem srv_crypt with path /srv
  #        if space usage > 80% then alert
  #        if inode usage > 80% then alert
  #    ''
  #  ];
  #  environment.systemPackages = [ letsgo pkgs.wol ];
  #  ptsd.nwbackup.paths = [ "/srv" ];
}
