{ config, lib, pkgs, ... }:

{
  ptsd.mosquitto = {
    enable = true;
    listeners = [{
      interface = "br0";
      address = "192.168.168.41";
    }];
  };

  services.home-assistant = {
    enable = true;
    package = pkgs.home-assistant-variants.dlrg;
  };

  # compensate flaky home-assistant <-> homematic connection
  systemd.services.restart-home-assistant = {
    description = "Restart home-assistant every morning";
    startAt = "*-*-* 03:30:00";
    serviceConfig = {
      ExecStart = "${pkgs.systemd}/bin/systemctl restart home-assistant.service";
    };
  };
}
