{ config, lib, pkgs, ... }:
let
  universe = import ../../2configs/universe.nix;
in
{
  imports =
    [
      ../..
      ../../2configs
      ../../2configs/hardened.nix
      ../../2configs/nwhost-mini.nix

      ../../2configs/prometheus-node.nix

      ./modules/bitwarden.nix
      ./modules/fraam-wordpress.nix
      ./modules/fraam-www.nix
      ./modules/fraamdb.nix
      ./modules/kanboard.nix
      ./modules/murmur.nix
      ./modules/wordpress.nix
    ];

  ptsd.nwbackup = {
    enable = true;
    paths = [
      "/var/backup"
      "/var/lib/fraam-www/www"
      "/var/lib/fraam-www/static"
      "/var/lib/kanboard"
      "/var/lib/bitwarden_rs"
      "/var/src"
    ];
  };

  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "htz3";
    interfaces.ens3 = {
      useDHCP = true;
      ipv6 = {
        addresses = [{ address = universe.hosts."${config.networking.hostName}".nets.www.ip6.addr; prefixLength = 64; }];
      };
    };

    # set to let wget use local connection
    extraHosts = ''
      127.0.0.1 dev.fraam.de
    '';

    # reduce noise coming from www if
    firewall.logRefusedConnections = false;

    firewall.allowedTCPPorts = [ 80 443 ];
  };

  services.journald.extraConfig = ''
    SystemMaxUse=1G
    RuntimeMaxUse=1G
  '';

  # prevents creation of the following route (`ip -6 route`):
  # default dev lo proto static metric 1024 pref medium
  systemd.network.networks."40-ens3".routes = [
    { routeConfig = { Gateway = "fe80::1"; }; }
  ];

  security.acme = {
    defaults.email = "enno.richter+letsencrypt@fraam.de";
    certs."voice.fraam.de".postRun = "systemctl restart murmur.service";
  };

  environment.systemPackages = with pkgs; [ tmux btop ptsd-nnn ];

  services.fail2ban.enable = true;

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {

      "fraam.de" = {
        addSSL = true;
        enableACME = true;

        locations = let jsonRes = data: ''
          add_header Access-Control-Allow-Origin https://chat.fraam.de;
          add_header Content-Type application/json;
          return 200 '${builtins.toJSON data}';
        ''; in
          {
            "/".extraConfig = "return 301 https://www.fraam.de;";
            "/.well-known/matrix/server".extraConfig = jsonRes { "m.server" = "matrix.fraam.de:443"; };
            "/.well-known/matrix/client".extraConfig = jsonRes { "m.homeserver".base_url = "https://matrix.fraam.de"; "m.identity_server".base_url = "https://vector.im"; };
          };
      };

      "auth.fraam.de" = { addSSL = true; enableACME = true; };
      "db.fraam.de" = { addSSL = true; enableACME = true; };
      "dev.fraam.de" = { addSSL = true; enableACME = true; };
      "int.fraam.de" = { addSSL = true; enableACME = true; };
      "pm.fraam.de" = { addSSL = true; enableACME = true; };
      "vault.fraam.de" = { addSSL = true; enableACME = true; };
      "voice.fraam.de" = { addSSL = true; enableACME = true; }; # dummy host for mumble cert fetching
      "www.fraam.de" = { addSSL = true; enableACME = true; };
    };
  };

  ptsd.oauth2-proxy = {
    enable = true;
    protectedHosts = [ "dev.fraam.de" "int.fraam.de" ];
  };

  system.stateVersion = "21.11";
}
