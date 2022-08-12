{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ./.
    ./users/enno.nix
    ./fish.nix
  ];

  virtualisation.hypervGuest.enable = true;

  boot.tmpOnTmpfs = true;

  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  systemd.network.networks."40-enp" = {
    matchConfig.Name = "enp*";
    networkConfig = {
      DHCP = "yes";
      IPv6PrivacyExtensions = "kernel";
    };
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  # as recommended by https://docs.syncthing.net/users/faq.html#inotify-limits
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 204800;

  environment.systemPackages = with pkgs;[ cryptsetup git home-manager ];

  ptsd.secrets.enable = false;
  ptsd.tailscale.enable = true;
  services.udisks2.enable = false;
  security.sudo.wheelNeedsPassword = false;
  nix.trustedUsers = [ "root" "@wheel" ];
}
