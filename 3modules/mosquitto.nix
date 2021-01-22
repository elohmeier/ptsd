{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.mosquitto;

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

  genListenerConf = l: ''
    listener ${if l.ssl then toString cfg.portSSL else toString cfg.portPlain}${optionalString (l.address != "") " ${l.address}"}
    ${optionalString (l.interface != "") "bind_interface ${l.interface}"}
    ${optionalString l.ssl ''
      certfile /var/lib/acme/${cfg.certDomain}/cert.pem
      keyfile /var/lib/acme/${cfg.certDomain}/key.pem
      tls_version tlsv1.2
      ciphers AES128-GCM-SHA256
    ''}
  '';

  mosquittoConf = pkgs.writeText "mosquitto.conf" ''
    acl_file ${aclFile}
    password_file /var/lib/mosquitto/passwd
    persistence true
    persistence_file /var/lib/mosquitto/mosquitto.db
    allow_anonymous false

    ${concatStringsSep "\n" (map genListenerConf cfg.listeners)}
  '';
in
{
  options = {
    ptsd.mosquitto = {
      enable = mkEnableOption "mosquitto";
      tasmotaUsername = mkOption {
        type = types.str;
        default = "tasmota";
      };
      certDomain = mkOption {
        type = types.str;
        default = "${config.networking.hostName}.${config.networking.domain}";
        description = "certificate beneath /var/lib/acme/";
      };
      portPlain = mkOption {
        type = types.int;
        default = 1883;
      };
      portSSL = mkOption {
        type = types.int;
        default = 8883;
      };
      listeners = mkOption {
        type = types.listOf (types.submodule {
          options = {
            interface = mkOption {
              type = types.str;
              default = "";
            };
            address = mkOption {
              type = types.str;
              default = "";
            };
            ssl = mkOption {
              type = types.bool;
              default = false;
            };
          };
        });
        default = [ ];
      };
    };
  };

  config = mkIf cfg.enable {

    # workaround https://github.com/eclipse/mosquitto/issues/1999
    # TODO: remove in 21.03/21.05?
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

    # generate passwd file using e.g. `nix-shell -p mosquitto --run "mosquitto_passwd -c -b pw tasmota $(pass mosquitto/dlrg/tasmota)"`
    ptsd.secrets.files."mosquitto.passwd" = { };

    systemd.services.mosquitto =
      let
        copyPasswd = pkgs.writers.writeDash "copy-mosquitto-passwd" ''
          cp ${config.ptsd.secrets.files."mosquitto.passwd".path} /var/lib/mosquitto/passwd
          chmod 400 /var/lib/mosquitto/passwd
        '';
      in
      {
        description = "Mosquitto MQTT Broker Daemon";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Type = "notify";
          NotifyAccess = "main";
          ExecStartPre = "+${copyPasswd}";
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
  };
}
