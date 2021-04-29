# Status: Work-in-Progress



{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.vdi-container;
  xephyrWrapper = pkgs.writeShellScriptBin "${cfg.name}-xephyr" ''
    ${pkgs.xorg.xorgserver}/bin/Xephyr \
      -resizeable \
      -br \
      -ac \
      -noreset \
      -screen 1920x1080 \
      -extension MIT-SHM -extension XTEST \
      -nolisten tcp \
      -keybd ephyr,xkbmodel=evdev,xkblayout='de(nodeadkeys)' \
      ${cfg.xephyrDisplayId}
  '';
  caWorkspace = pkgs.callPackage <ptsd/5pkgs/citrix-workspace/wrapper.nix> {
    extraCerts = cfg.extraCerts;
  };
in
{
  options.ptsd.vdi-container = {
    enable = mkEnableOption "vdi-container: containerized AnyConnect VPN / Citrix VDI setup";
    extIf = mkOption {
      type = types.str;
      default = "eth0";
      description = "external network interface container traffic will be NATed over";
    };
    name = mkOption {
      type = types.str;
      default = "vdi";
    };
    containerAddress = mkOption {
      type = types.str;
      default = "192.168.100.12";
      description = "IP address of the container in the private host/container-network";
    };
    hostAddress = mkOption {
      type = types.str;
      default = "192.168.100.10";
      description = "IP address of the host in the private host/container-network";
    };
    xephyrDisplayId = mkOption {
      type = types.str;
      default = ":1";
    };
    startupUrls = mkOption {
      type = types.listOf (types.str);
      description = "URLs Firefox should open automatically after startup, e.g. Login web page for Firewalls etc.";
      default = [ ];
    };
    containerTimeZone = mkOption {
      type = types.str;
      default = "Europe/Berlin";
      description = "Will be forwarded to the Citrix Remote";
    };
    containerLocale = mkOption {
      type = types.str;
      default = "de_DE.UTF-8";
    };
    extraCerts = mkOption {
      type = types.listOf (types.str);
      default = [ ];
      description = "Extra CA Certificates for Citrix Workspace";
    };
    vpnUsername = mkOption {
      type = types.str;
    };
    vpnUrl = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {

    networking = {
      nat = {
        enable = true;
        internalInterfaces = [ "ve-+" ];
        externalInterface = cfg.extIf;
      };

      extraHosts = ''
        ${cfg.containerAddress} ${cfg.name}
      '';
    };

    environment.systemPackages = [ xephyrWrapper ];

    systemd.services."container@${cfg.name}".serviceConfig.TimeoutStopSec = "10s";

    containers."${cfg.name}" = {
      autoStart = false;
      enableTun = true;
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.containerAddress;
      bindMounts = {
        "/tmp/.X11-unix" = {
          hostPath = "/tmp/.X11-unix";
          isReadOnly = true; # X11 clients won't need write access, if false the socket will be *removed*
        };
      };

      config =
        { config, pkgs, ... }:
        {
          imports = [
            <ptsd>
            <ptsd/2configs>

          ];

          boot.isContainer = true;

          environment = {
            etc."X11/icewm/startup" = {
              text = ''
                ${pkgs.firefox}/bin/firefox \
                  --no-remote \
                  ${lib.concatMapStrings (x: " \"${x}\"") cfg.startupUrls}
              '';
              mode = "0755";
            };
            shellAliases = {
              vpn = "sudo openconnect --user=${cfg.vpnUsername} ${cfg.vpnUrl}";
              iwm = "icewm-session";
            };
            systemPackages = with pkgs; [
              caWorkspace
              dnsutils
              firefox
              openconnect
              icewm
            ];
            variables = {
              DISPLAY = cfg.xephyrDisplayId;
              ICEWM_PRIVCFG = "/etc/X11/icewm";
            };
          };

          networking = {
            useHostResolvConf = false;
            nameservers = [ "8.8.8.8" "8.8.4.4" ]; # will be used for VPN DNS lookup
            useNetworkd = true;
          };

          time.timeZone = cfg.containerTimeZone;

          i18n = {
            defaultLocale = cfg.containerLocale;
            supportedLocales = [ "${cfg.containerLocale}/UTF-8" ];
          };

          security.sudo.extraRules = lib.mkAfter [
            {
              users = [ config.users.users.mainUser.name ];
              commands = [{ command = "${pkgs.openconnect}/bin/openconnect"; options = [ "NOPASSWD" "SETENV" ]; }];
            }
          ];

          users.motd = ''
                        ** Welcome **

            1. Launch "${cfg.name}-xephyr" on the host
            2. Use "sudo openconnect --user=${cfg.vpnUsername} ${cfg.vpnUrl}" (aliased to "vpn") to connect to the VPN.
            3. Run "icewm-session" (aliased to "iwm", inside the container)
            4. In Firefox: Login to the Firewall && Login to Citrix and open the connection file (e.g. from the browser)
               URLs: ${lib.concatMapStrings (x: "\n   - ${x}") cfg.startupUrls}
            5. ????
            6. PROFIT!!!
          '';

          home-manager = {
            users.mainUser = { pkgs, ... }:
              {
                # prevent eula dialog
                home.file.".ICAClient/.eula_accepted".text = '''';
              };
          };
        };
    };
  };
}
