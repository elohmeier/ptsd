{ config, lib, pkgs, ... }:

let
  sshPubKeys = import ./ssh-pubkeys.nix;
  authorizedKeys = [
    sshPubKeys.sshPub.nw1
    sshPubKeys.sshPub.nw15_terminus
    sshPubKeys.sshPub.nw15_workingcopy
    sshPubKeys.sshPub.nw30
    sshPubKeys.sshPub.nw30_win10
    sshPubKeys.sshPub.ws1
    sshPubKeys.sshPub.enno_yubi41
    sshPubKeys.sshPub.enno_yubi49
  ];
in
{
  environment.shellAliases = import ./aliases.nix;

  users = {
    mutableUsers = false;

    users.root = {
      openssh.authorizedKeys.keys = authorizedKeys;
    };

    users.enno = {
      isNormalUser = true;
      home = "/home/enno";
      useDefaultShell = true;
      uid = 1000;
      description = "Enno Lohmeier";
      extraGroups =
        [ "wheel" "networkmanager" "libvirtd" "docker" "syncthing" "video" ];
      openssh.authorizedKeys.keys = authorizedKeys;
    };
  };

  boot.initrd.network.ssh.authorizedKeys = authorizedKeys;

  i18n.defaultLocale = "de_DE.UTF-8";

  time.timeZone = "Europe/Berlin";

  services.timesyncd = {
    enable = true;
    servers = [
      "0.de.pool.ntp.org"
      "1.de.pool.ntp.org"
      "2.de.pool.ntp.org"
      "3.de.pool.ntp.org"
    ];
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "prohibit-password";
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };

  programs.mosh.enable = true;
  services.fail2ban.enable = true;

  environment.etc."ssh/ssh_known_hosts".text = ''
    ${sshPubKeys.hostPub.nuc1}
    ${sshPubKeys.hostPub.apu1}
    ${sshPubKeys.hostPub.eee1}
    ${sshPubKeys.hostPub.htz1}
    ${sshPubKeys.hostPub.htz2}
  '';
}
