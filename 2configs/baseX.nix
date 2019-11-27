{ config, lib, pkgs, ... }:


{
  imports = [
    <ptsd/2configs/nwhost.nix>

    <ptsd/3modules>
  ];

  ptsd.nwtelegraf.enable = true;

  # Make sure zsh lands in /etc/shells
  # to not be affected by user not showing up in LightDM
  # as in https://discourse.nixos.org/t/normal-users-not-appearing-in-login-manager-lists/4619
  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;

  # as recommended in
  # https://github.com/rycee/home-manager/blob/master/modules/programs/zsh.nix
  environment.pathsToLink = [ "/share/zsh" ];

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOfBoot = true;
  virtualisation.libvirtd.enable = true;
}
