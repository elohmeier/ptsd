# Use "make iso" to build

{ config, lib, pkgs, ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>

    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/tor-ssh.nix>

    <secrets-shared/nwsecrets.nix>
  ];

  # enable zfs encryption
  boot.zfs.enableUnstable = true;

  # override default installer behaviour and start sshd by default
  systemd.services.sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];

  i18n.consoleKeyMap = "de-latin1";

  environment.systemPackages = with pkgs; [ tmux ncdu git mc ];

  services.resolved.enable = true;
  networking.wireless.enable = false;
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };

  #  boot.kernelParams = [ "console=tty0" "console=ttyS0,115200n8" ];
}
