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

    package = unstable.octoprint;
    plugins = plugins: [ (plugins.callPackage ../5pkgs/octoprint-plugins/bedlevelvisualizer.nix {}) ];
    deviceService = "sys-devices-pci0000:00-0000:00:15.0-usb1-1\\x2d3-1\\x2d3:1.0-ttyUSB0-tty-ttyUSB0.device";
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
