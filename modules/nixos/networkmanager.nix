{
  config,
  lib,
  pkgs,
  ...
}:

{
  networking = {
    useDHCP = false;
    useNetworkd = true;
    wireless.iwd.enable = true;
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      plugins = lib.mkForce [ ];
      wifi = {
        backend = "iwd";
        macAddress = "random";
        powersave = true;
      };
    };
  };

  services.resolved = {
    enable = true;
  };

  boot = {
    kernelModules = [ "tcp_bbr" ];

    # speed up networking, affects both IPv4 and IPv6r
    kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
  };

  hardware.firmware = with pkgs; [
    firmwareLinuxNonfree
    broadcom-bt-firmware # for the plugable USB stick
  ];
}
