{ config, pkgs, ... }:
{
  ptsd.octoprint = {
    enable = true;
    port = config.ptsd.ports.octoprint;

    package = pkgs.octoprint;
    plugins = plugins:
      let
        ptsdPlugins = pkgs.ptsd-octoprintPlugins plugins;
      in
      [
        plugins.printtimegenius
        plugins.telegram
        ptsdPlugins.firmwareupdater
        ptsdPlugins.octolapse
        ptsdPlugins.prusalevelingguide
        ptsdPlugins.prusaslicerthumbnails
      ];
    #deviceService = "sys-devices-pci0000:00-0000:00:15.0-usb1-1\\x2d3-1\\x2d3:1.0-ttyUSB0-tty-ttyUSB0.device";
    webcamStreamUrl = "https://nas1.pug-coho.ts.net:${toString config.ptsd.ports.mjpg-streamer}/?action=stream";
    webcamSnapshotUrl = "https://nas1.pug-coho.ts.net:${toString config.ptsd.ports.mjpg-streamer}/?action=snapshot";
    serialDevice = "/dev/ttyACM0"; # prusa

    extraConfig = {
      plugins.firmwareupdater = {
        _selected_profile = 0;
        profiles = [{
          # prusa config
          _name = "Default";
          flash_method = "avrdude";
          avrdude_avrmcu = "m2560";
          avrdude_path = "${pkgs.avrdude}/bin/avrdude";
          avrdude_programmer = "wiring";
          serial_port = "/dev/ttyACM0";
        }];
      };
    };
  };

  # environment.systemPackages = [ (pkgs.v4l-utils.override { withGUI = false; }) ];

  ptsd.mjpg-streamer = {
    enable = true;
    inputPlugin = "input_uvc.so -f 30 -r 1280x720";
    outputPlugin = "output_http.so -w @www@ -n -l 127.0.0.1 -p ${toString config.ptsd.ports.mjpg-streamer}";
    #deviceService = "sys-devices-pci0000:00-0000:00:15.0-usb1-1\\x2d7-1\\x2d7:1.2-sound-card1.device";
  };
}
