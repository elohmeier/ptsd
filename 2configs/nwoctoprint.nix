{ config, pkgs, ... }:
let
  unstable = import <nixpkgs-unstable> { };
  domain = "octoprint.services.nerdworks.de";
  v4l-utils-nogui = pkgs.v4l-utils.override { withGUI = false; };
in
{
  ptsd.octoprint = {
    enable = true;
    host = "127.0.0.1";
    port = config.ptsd.nwtraefik.ports.octoprint;

    package = unstable.octoprint;
    plugins = plugins: [
      (plugins.callPackage ../5pkgs/octoprint-plugins/bedlevelvisualizer.nix { })
      plugins.printtimegenius
      (plugins.callPackage ../5pkgs/octoprint-plugins/telegram.nix { })
    ];
    webcamStreamUrl = "https://${domain}/mjpg/?action=stream";
    webcamSnapshotUrl = "https://${domain}/mjpg/?action=snapshot";
  };

  environment.systemPackages = [ v4l-utils-nogui ];

  ptsd.mjpg-streamer = {
    enable = true;
    inputPlugin = "input_uvc.so -f 30 -r 1280x720";
    outputPlugin = "output_http.so -w @www@ -n -p ${toString config.ptsd.nwtraefik.ports.mjpg-streamer}";
    deviceService = "sys-devices-pci0000:00-0000:00:15.0-usb1-1\\x2d7-1\\x2d7:1.2-sound-card1.device";
  };

  ptsd.nwtraefik.services = [
    {
      name = "octoprint";
      rule = "Host(`${domain}`)";
    }
    {
      name = "mjpg-streamer";
      rule = "Host(`${domain}`) && PathPrefix(`/mjpg/`)";
      stripPrefixes = [ "/mjpg/" ];
    }
  ];
}
