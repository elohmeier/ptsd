{ config, lib, pkgs, ... }:

let
  fluentConfig = pkgs.writeText "fluent.conf" ''
    [SERVICE]
      flush 5
      log_level info
      daemon off

    [INPUT]
      Name systemd
      Tag *
      Read_From_Tail true

    [OUTPUT]
      Name loki
      Match *
      Host htz1.pug-coho.ts.net
      port ${toString config.ptsd.ports.loki}
      labels job=journald,host=${config.networking.hostName}
  '';
in
{
  systemd.services.fluent-bit = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    description = "Fluent Bit log processor and forwarder";
    serviceConfig = {
      ExecStart = "${pkgs.fluent-bit}/bin/fluent-bit --config=${fluentConfig}";
    };
  };

  environment.systemPackages = [ pkgs.fluent-bit ];
}
