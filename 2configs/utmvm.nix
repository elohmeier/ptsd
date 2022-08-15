{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./devenv.nix
  ];

  boot = {
    binfmt.emulatedSystems = [ "x86_64-linux" ];
    initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "usbhid" "usb_storage" "sr_mod" ];
  };

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
}
