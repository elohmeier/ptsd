{ pkgs, ... }:

{
  imports = [
    ../..
    ../../2configs
    ../../2configs/borgbackup.nix
    ../../2configs/nwhost-mini.nix
    ../../2configs/minimal.nix
    ../../2configs/prometheus-node.nix

    #./modules/home-assistant.nix
    #./modules/mosquitto.nix
    ./modules/networking.nix
    ./modules/nginx.nix
  ];

  services.borgbackup.jobs.rpi4 = {
    paths = [ "/var/lib/hass" ];
    exclude = [
      "home-assistant_v2.db*"
      "home-assistant.log*"
    ];
  };

  environment.systemPackages = with pkgs; [
    btop
    vim
    tcpdump
    nmap
    ptsd-python3.pkgs.tasmota-decode-config
  ];

  systemd.services.restart-system = {
    description = "Restart system every morning";
    startAt = "*-*-* 03:30:00";
    serviceConfig = {
      ExecStart = "${pkgs.systemd}/bin/systemctl reboot";
    };
  };

  system.stateVersion = "21.11";
}
