# Keep in mind this config is also used for NixOS containers.
with import <ptsd/lib>;
{ config, pkgs, ... }:

let
  sshPubKeys = import ./ssh-pubkeys.nix;
  authorizedKeys = [
    sshPubKeys.sshPub.mb1
    sshPubKeys.sshPub.iph1_terminus
    sshPubKeys.sshPub.iph1_workingcopy
    sshPubKeys.sshPub.tp1
    sshPubKeys.sshPub.tp1_win10
    sshPubKeys.sshPub.ws1
    sshPubKeys.sshPub.enno_yubi41
    sshPubKeys.sshPub.enno_yubi49
  ];
  vims = pkgs.callPackage ./vims.nix {};
in
{
  imports = [
    {
      users.users =
        mapAttrs (_: h: { hashedPassword = h; })
          (import <secrets/hashedPasswords.nix>);
    }
    {
      users.users = {
        root = {
          openssh.authorizedKeys.keys = authorizedKeys;
        };

        mainUser = {
          name = "enno";
          isNormalUser = true;
          home = "/home/enno";
          createHome = true;
          useDefaultShell = true;
          uid = 1000;
          description = "Enno Lohmeier";
          extraGroups =
            [ "wheel" "networkmanager" "libvirtd" "docker" "syncthing" "video" ];
          openssh.authorizedKeys.keys = authorizedKeys;
        };
      };
    }
  ];

  environment.shellAliases = import ./aliases.nix;

  users.mutableUsers = false;

  environment.variables = {
    NIX_PATH = mkForce "secrets=/var/src/ptsd/null:/var/src";
  };

  boot.initrd.network.ssh.authorizedKeys = authorizedKeys;

  i18n.defaultLocale = "de_DE.UTF-8";

  time.timeZone = "Europe/Berlin";

  services.openssh = {
    enable = true;
    permitRootLogin = mkDefault "prohibit-password";
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

  environment.systemPackages = with pkgs; [
    vims.small
    tmux
    git
    dnsutils
  ];
}
