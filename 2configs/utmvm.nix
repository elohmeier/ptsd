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
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "cifs" ];
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

  fileSystems = {
    "/" = {
      device = "/dev/vda2";
      fsType = "xfs";
    };

    "/boot" = {
      device = "/dev/vda1";
      fsType = "vfat";
    };
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
}
