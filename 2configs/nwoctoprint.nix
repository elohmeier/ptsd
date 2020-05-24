{ config, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {};
  domain = "octoprint.services.nerdworks.de";
in
{
  ptsd.octoprint = {
    enable = true;
    host = "127.0.0.1";
    port = config.ptsd.nwtraefik.ports.octoprint;

    package = (unstable.callPackage ../5pkgs/octoprint {});
    plugins = plugins: with plugins; [ bedlevelvisualizer ];
    deviceService = "sys-devices-pci0000:00-0000:00:15.0-usb1-1\\x2d7-1\\x2d7:1.0-ttyUSB0-tty-ttyUSB0.device";
  };

  ptsd.lego.extraDomains = [
    domain
  ];

  ptsd.nwtraefik.services = [
    {
      name = "octoprint";
      rule = "Host:${domain}";
    }
  ];
}
