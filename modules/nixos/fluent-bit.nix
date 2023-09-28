{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.fluent-bit;
  toLoki = pkgs.lib.generators.toINI {
    mkKeyValue = k: v: "  ${k} ${toString v}";
  };
  parserConfig = pkgs.writeText "fluent-bit-parsers.conf" (toLoki {
    PARSER = {
      name = "traefik";
      format = "json";
      time_key = "time";
      time_format = "%Y-%m-%dT%H:%M:%S%z";
      decode_field_as = "escaped json";
    };
  });
  fluentConfig = pkgs.writeText "fluent-bit.conf" (toLoki {
    SERVICE = {
      flush = 5;
      daemon = "off";
      log_level = "info";
      parsers_file = toString parserConfig;
    };

    # todo: gen config by just piling up includes
    # see https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/configuration-file#config_include_file-1

    INPUT = #[
      {
        name = "systemd";
        tag = "*";
        read_from_tail = "on"; # skip old journal entries
      };
    #    {
    #      name = "tail";
    #      path = "/var/log/traefik/access.log.json";
    #      tag = "traefik";
    #    }
    #  ];

    OUTPUT = {
      name = "loki";
      match = "*";
      host = "127.0.0.1";
      port = config.ptsd.ports.loki;
      labels = "job=fluent-bit,host=${config.networking.hostName}";
    };
  });
in
{
  options.ptsd.fluent-bit = {
    enable = mkEnableOption "ptsd.fluent-bit";
  };

  config = mkIf cfg.enable {

    systemd.services.fluent-bit = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Fluent Bit log processor and forwarder";
      serviceConfig = {
        #DynamicUser = true;
        ExecStart = "${pkgs.fluent-bit}/bin/fluent-bit --config=${fluentConfig}";
        EnvironmentFile = config.ptsd.secrets.files."fluent-bit.env".path;
        #SupplementaryGroups = "keys traefik";
      };
    };

    ptsd.secrets.files."fluent-bit.env" = {
      dependants = [ "fluent-bit.service" ];
    };

    environment.systemPackages = [ pkgs.fluent-bit ];
  };

}
