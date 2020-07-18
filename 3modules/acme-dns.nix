{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.acme-dns;
  configOptions = {
    api = cfg.apiOptions;
    general = {
      domain = cfg.domain;
      nsname = cfg.nsname;
      nsadmin = cfg.nsadmin;
      records = cfg.records;
      debug = false;
    } // cfg.generalOptions;
    database = {
      engine = "sqlite3";
      connection = "/var/lib/acme-dns/acme-dns.db";
    };
    logconfig = {
      #loglevel = "debug"; # error, warning, info or debug
      loglevel = "warning"; # error, warning, info or debug
      logtype = "stdout";
      logformat = "text";
    };
  };
  configFile =
    pkgs.runCommand "config.toml"
      {
        buildInputs = [ pkgs.remarshal ];
        preferLocalBuild = true;
      } ''
      remarshal -if json -of toml \
        < ${pkgs.writeText "config.json"
        (builtins.toJSON configOptions)} \
        > $out
    '';
in
{
  options.ptsd.acme-dns = {
    enable = mkEnableOption "acme-dns";
    generalOptions = mkOption {
      description = "General config for acme-dns.";
      type = types.attrs;
    };
    domain = mkOption { type = types.str; };
    nsname = mkOption { type = types.str; };
    nsadmin = mkOption { type = types.str; };
    records = mkOption { type = with types; listOf str; };
    apiOptions = mkOption {
      description = "API config for acme-dns.";
      type = types.attrs;
    };
    package = mkOption {
      type = types.package;
      default = pkgs.acme-dns;
      defaultText = "pkgs.acme-dns";
    };
  };

  config = mkIf cfg.enable {

    systemd.services."acme-dns" = {
      description = "acme-dns DNS server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      wants = [ "network.target" ];

      # this blocks systemd-resolved local DNS server
      # needed until https://github.com/joohoi/acme-dns/issues/135 is fixed
      before = [ "systemd-resolved.service" ]; #

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/acme-dns -c ${configFile}";
        PrivateTmp = true;
        ProtectSystem = "full";
        ProtectHome = true;
        CapabilityBoundingSet = "cap_net_bind_service";
        AmbientCapabilities = "cap_net_bind_service";
        NoNewPrivileges = true;
        DynamicUser = true;
        StateDirectory = "acme-dns";
        Restart = "on-failure";
      };
    };

  };

}
