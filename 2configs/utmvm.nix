{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./.
    ./users/enno.nix
    ./fish.nix
  ];

  boot = {
    binfmt.emulatedSystems = [ "x86_64-linux" ];
    initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "usbhid" "usb_storage" "sr_mod" ];
    tmpOnTmpfs = true;
    initrd.systemd = {
      enable = true;
      emergencyAccess = true;
    };
  };

  networking = {
    useDHCP = false;
    useNetworkd = true;
    firewall.trustedInterfaces = [ "enp0s6" ];
  };

  systemd.network.networks."40-enp" = {
    matchConfig.Driver = "virtio_net";
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
    cryptsetup
    git
    home-manager
  ];

  # not supported on aarch64-linux
  # environment.unixODBCDrivers = [ pkgs.unixODBCDrivers.msodbcsql17 ];

  environment.etc."odbcinst.ini".text = ''
    [FreeTDS]
    Description = FreeTDS Driver
    Driver = ${pkgs.freetds}/lib/libtdsodbc.so
  '';

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

  hardware.firmware = [
    (pkgs.runCommand "firmware-belkin-usb-c" { } ''
      mkdir -p $out/lib/firmware/rtl_nic
      cp ${pkgs.firmwareLinuxNonfree}/lib/firmware/rtl_nic/rtl8153a-4.fw $out/lib/firmware/rtl_nic/
    '')
  ];
}
