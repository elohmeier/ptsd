{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./.
    ./users/enno.nix
    ./fish.nix
  ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "usbhid" "usb_storage" "sr_mod" ];
    tmpOnTmpfs = true;
  };

  networking = {
    useDHCP = false;
    useNetworkd = true;
    firewall.enable = false;
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

  environment.systemPackages = with pkgs;[
    git
    home-manager
  ];

  ptsd.secrets.enable = false;
  ptsd.tailscale.enable = true;
  services.spice-vdagentd.enable = true;
  services.udisks2.enable = false;
  security.sudo.wheelNeedsPassword = false;
  nix.trustedUsers = [ "root" "@wheel" ];

  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${config.networking.hostName}
      netbios name = ${config.networking.hostName}
    '';
    shares = {
      home = {
        path = "/home/enno";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
    };
  };
}
