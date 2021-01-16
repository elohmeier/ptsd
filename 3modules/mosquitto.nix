{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.mosquitto;
  secrets = import <secrets/mosquittoHashedPasswords.nix>;


  users = {
    hass = {
      acl = [
        "topic readwrite cmnd/#"
        "topic readwrite stat/#"
        "topic readwrite tele/#"
        "topic readwrite homeassistant/#"
      ];
    };
    # see https://tasmota.github.io/docs/MQTT/#mqtt-topic-definition
    "${cfg.tasmotaUsername}" = {
      acl = [
        "topic readwrite cmnd/#"
        "topic readwrite stat/#"
        "topic readwrite tele/#"
        "topic readwrite homeassistant/#"
      ];
    };
  };

  aclFile = pkgs.writeText "mosquitto.acl" (concatStringsSep "\n\n" (mapAttrsToList
    (n: c:
      "user ${n}\n" + (concatStringsSep "\n" c.acl))
    users));

  mosquittoConf = pkgs.writeText "mosquitto.conf" ''
    acl_file ${aclFile}
    password_file /var/lib/mosquitto/passwd
    persistence true
    persistence_file /var/lib/mosquitto/mosquitto.db
    allow_anonymous false
    listener 8883
    bind_interface ${cfg.interface}
    cafile /etc/ssl/certs/ca-certificates.crt
    certfile /var/lib/acme/${cfg.certDomain}/cert.pem
    keyfile /var/lib/acme/${cfg.certDomain}/key.pem
  '';
in
{
  options = {
    ptsd.mosquitto = {
      enable = mkEnableOption "mosquitto";
      interface = mkOption {
        type = types.str;
      };
      tasmotaUsername = mkOption {
        type = types.str;
        default = "tasmota";
      };
      certDomain = mkOption {
        type = types.str;
        default = "${config.networking.hostName}.${config.networking.domain}";
        description = "certificate beneath /var/lib/acme/";
      };
    };
  };

  # generate pw file using e.g. `nix-shell -p mosquitto --run "mosquitto_passwd -c -b pw tasmota $(pass mosquitto/dlrg/tasmota)"`
  config = mkIf cfg.enable {

    # workaround https://github.com/eclipse/mosquitto/issues/1999
    nixpkgs.config.packageOverrides = pkgs: {
      mosquitto = pkgs.mosquitto.overrideAttrs (oldAttrs: rec {
        version = "2.0.5";
        src = pkgs.fetchFromGitHub {
          owner = "eclipse";
          repo = "mosquitto";
          rev = "v${version}";
          sha256 = "17lnr5v83wcxb22yf63fqzp1cd1bf5cpr700371xw040cgvjwn09";
        };
      });
    };

    ptsd.secrets.files."mosquitto.passwd" = { };

    # TODO: generate passwd file
    systemd.services.mosquitto = {
      description = "Mosquitto MQTT Broker Daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "notify";
        NotifyAccess = "main";
        ExecStart = "${pkgs.mosquitto}/bin/mosquitto -c ${mosquittoConf}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        DynamicUser = true;
        Restart = "always";
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        NoNewPrivileges = true;
        LimitNPROC = 64;
        LimitNOFILE = 64;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        StateDirectory = "mosquitto";
        SupplementaryGroups = "certs";
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = "AF_INET AF_INET6";
        RestrictNamespaces = true;
        DevicePolicy = "closed";
        RestrictRealtime = true;
        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";
        SystemCallArchitectures = "native";
      };
    };

    #    services.mosquitto = {
    #      enable = true;
    #      allowAnonymous = false;
    #      checkPasswords = true;
    #      ssl = {
    #        enable = true;
    #        cafile = "/etc/ssl/certs/ca-certificates.crt";
    #        certfile = "/var/lib/acme/${cfg.certDomain}/cert.pem";
    #        keyfile = "/var/lib/acme/${cfg.certDomain}/key.pem";
    #      };
    #      users = {
    #        hass = {
    #          acl = [
    #            "topic readwrite cmnd/#"
    #            "topic readwrite stat/#"
    #            "topic readwrite tele/#"
    #            "topic readwrite homeassistant/#"
    #          ];
    #          hashedPassword = secrets.hass;
    #        };
    #        # see https://tasmota.github.io/docs/MQTT/#mqtt-topic-definition
    #        "${cfg.tasmotaUsername}" = {
    #          acl = [
    #            "topic readwrite cmnd/#"
    #            "topic readwrite stat/#"
    #            "topic readwrite tele/#"
    #            "topic readwrite homeassistant/#"
    #          ];
    #          hashedPassword = secrets."${cfg.tasmotaUsername}";
    #        };
    #      };
    #      extraConf = ''
    #        bind_interface ${cfg.interface}
    #      '';
    #    };
    #
    #    users.groups.certs.members = [ "mosquitto" ];
  };
}
