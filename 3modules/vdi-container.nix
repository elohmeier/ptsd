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
    citrix_workspace = cfg.citrixWorkspaceUnwrappedPackage;
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
      default = [];
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
    citrixWorkspaceUnwrappedPackage = mkOption {
      default = pkgs.citrix_workspace_unwrapped;
      type = types.package;
      defaultText = "pkgs.citrix_workspace_unwrapped";
      description = "Citrix Workspace (unwrapped) derivation to use. Extra CAs will be added to this.";
    };
    extraCerts = mkOption {
      type = types.listOf (types.str);
      default = [];
      description = "Extra CA Certificates for Citrix Workspace";
    };
    vpnHosts = mkOption {
      type = types.attrs;
      description = "Hosts to be made available over the VPN connection. Routes will be set and Hosts-File Entries will be added in the container.";
    };
    vpnUsername = mkOption {
      type = types.str;
    };
    vpnPassword = mkOption {
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

    containers."${cfg.name}" = {
      autoStart = true;
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

            environment.variables = {
              DISPLAY = cfg.xephyrDisplayId;
              ICEWM_PRIVCFG = "/etc/X11/icewm";
            };

            environment.etc."X11/icewm/startup" = {
              text = ''
                ${pkgs.firefox}/bin/firefox \
                  --no-remote \
                  ${lib.concatMapStrings (x: " \"${x}\"") cfg.startupUrls}
              '';
              mode = "0755";
            };

            networking = {
              useHostResolvConf = false;
              nameservers = [ "8.8.8.8" "8.8.4.4" ]; # will be used for VPN DNS lookup

              extraHosts = concatStringsSep "\n" (mapAttrsToList (ip: hostname: ip + " " + hostname) cfg.vpnHosts);
            };

            time.timeZone = cfg.containerTimeZone;

            i18n = {
              defaultLocale = cfg.containerLocale;
              supportedLocales = [ "${cfg.containerLocale}/UTF-8" ];
            };

# TODO: Allow systemctl without password, not working currently
#            security.sudo.extraRules = [
#              {
#                groups = [ "vpn" ];
#                commands = [ { command = "${pkgs.systemd}/bin/systemctl"; options = [ "NOPASSWD" ]; } ];
#              }
#            ];
#
#            users.groups.vpn = {};
#            users.users.mainUser.extraGroups = [ "vpn" ];

            users.motd = ''
                          ** Welcome **

              1. Launch "${cfg.name}-xephyr" on the host
              2. Use "sudo systemctl start vpn" to connect to the VPN.
              3. Run "icewm-session" inside the container
              4. In Firefox: Login to the Firewall && Login to Citrix and open the connection file (e.g. from the browser)
              5. ????
              6. PROFIT!!!
            '';

            environment.systemPackages = with pkgs; [
              caWorkspace
              firefox
              openconnect
              icewm
            ];

            systemd.services.vpn = {
              description = "OpenConnect VPN connection";
              requires = [ "network-online.target" ];
              after = [ "network.target" "network-online.target" ];
              path = with pkgs; [
                nettools
                inetutils
              ];
              serviceConfig = {
                ExecStart = "${pkgs.bash}/bin/bash -c 'echo ${cfg.vpnPassword} | ${pkgs.openconnect}/bin/openconnect --user=${cfg.vpnUsername} --passwd-on-stdin ${cfg.vpnUrl}'";
                Restart = "no";
              };
              postStart = ''
                # Wait for tun0 to come up
                while ! grep -q tun0 </proc/net/dev; do sleep 1; done

                # Add routes
                ${concatStringsSep "\n" (mapAttrsToList (ip: _: "${pkgs.iproute}/bin/ip route add " + ip + "/32 dev tun0") cfg.vpnHosts)}
              '';
            };
          };
    };
  };
}
