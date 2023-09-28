{ pkgs, ... }:

{
  imports = [
    ../../2configs
    ../../2configs/fish.nix
    ../../2configs/prometheus-node.nix
    ../../2configs/rpi3b_4.nix
    ../../2configs/users/enno.nix

    ./octoprint.nix
  ];

  services.getty.autologinUser = "enno";
  security.sudo.wheelNeedsPassword = false;
  nix.trustedUsers = [ "root" "@wheel" ];
  system.stateVersion = "22.05";
  networking.hostName = "rpi3";

  environment.systemPackages = with pkgs;[ vim tmux btop ];

  ptsd.tailscale = {
    enable = true;
    cert.enable = true;
    httpServices = [ "octoprint" ];
  };

  systemd.services.rpi-powersave = {
    description = "Set some tunables to save power";
    wantedBy = [ "multi-user.target" ];
    script = ''
      # Turn off HDMI
      ${pkgs.libraspberrypi}/bin/tvservice -o

      echo 'auto' > '/sys/bus/usb/devices/1-1.1/power/control'
    '';
  };
}
