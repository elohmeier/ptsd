{ config, lib, pkgs, ... }:

{
  imports = [
    ../../../2configs/printers/hl5380dn.nix
  ];

  networking.firewall.interfaces.wlan0 = {
    # samba/cups ports
    allowedTCPPorts = [ 631 445 139 ];
    allowedUDPPorts = [ 631 137 138 ];
  };

  # wifi credentials
  ptsd.secrets.files."fraam.psk".path = "/var/lib/iwd/fraam.psk";

  ptsd.cups-airprint = {
    enable = true;
    lanDomain = "lan";
    listenAddress = "192.168.1.133:631";
    printerName = "HL5380DN";
  };
}
