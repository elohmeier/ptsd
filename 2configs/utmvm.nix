{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    # ./devenv.nix # TODO
  ];

  boot.initrd.availableKernelModules = [
    "sr_mod"
    "usb_storage"
    "usbhid"
    "virtio_pci"
    "virtiofs"
    "xhci_pci"
  ];

  networking = {
    firewall.trustedInterfaces = [ "enp0s6" ];
  };

  systemd.network.networks."40-enp" = {
    matchConfig.Driver = "virtio_net";
    networkConfig = {
      DHCP = "yes";
      IPv6PrivacyExtensions = "kernel";
    };
  };


  # not supported on aarch64-linux
  # environment.unixODBCDrivers = [ pkgs.unixODBCDrivers.msodbcsql17 ];

  environment.etc."odbcinst.ini".text = ''
    [FreeTDS]
    Description = FreeTDS Driver
    Driver = ${pkgs.freetds}/lib/libtdsodbc.so
  '';

  services.spice-vdagentd.enable = true;

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

  services.openssh.extraConfig = ''
    AcceptEnv TERM_PROGRAM LC_TERMINAL
  '';

  fileSystems."/run/rosetta" = {
    device = "rosetta";
    fsType = "virtiofs";
  };

  nix.settings = {
    extra-platforms = [ "x86_64-linux" ];
    extra-sandbox-paths = [ "/run/rosetta" "/run/binfmt" ];
  };

  boot.binfmt.registrations."rosetta" = {
    # based on https://developer.apple.com/documentation/virtualization/running_intel_binaries_in_linux_vms_with_rosetta#3978495
    interpreter = "/run/rosetta/rosetta";
    fixBinary = true;
    wrapInterpreterInShell = false;
    matchCredentials = true;
    magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
    mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
  };
}
