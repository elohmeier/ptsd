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
