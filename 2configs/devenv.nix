{ config, lib, pkgs, ... }:

{
  imports = [
    ./.
    ./users/enno.nix
    ./fish.nix
  ];

  boot = {
    tmpOnTmpfs = true;
    initrd.systemd = {
      enable = true;
      emergencyAccess = true;
    };
  };
  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  # as recommended by https://docs.syncthing.net/users/faq.html#inotify-limits
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 204800;

  environment.systemPackages = with pkgs;[
    cifs-utils
    cryptsetup
    git
    home-manager
  ];

  ptsd.secrets.enable = false;
  ptsd.tailscale.enable = true;

  services.udisks2.enable = lib.mkDefault false;
  security.sudo.wheelNeedsPassword = false;
  nix.settings.trusted-users = [ "root" "@wheel" ];

  services.getty.autologinUser = "enno";
}
