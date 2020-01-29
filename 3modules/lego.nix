{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.lego;
  unit-script-post = pkgs.writeShellScriptBin "unit-script-lego-post" ''
    set -e

    # set permissions
    ${pkgs.coreutils}/bin/chmod 750 "${cfg.home}"
    ${pkgs.coreutils}/bin/mkdir -p "${cfg.home}/certificates"
    ${pkgs.coreutils}/bin/chown -R lego:lego "${cfg.home}/certificates"
    ${pkgs.coreutils}/bin/chmod -R ug=r,u+w,a+X "${cfg.home}/certificates"

    # create a root-owned copy e.g. for PostgreSQL
    ${pkgs.rsync}/bin/rsync -avh --delete "${cfg.home}/certificates/" "${cfg.home}/certificates-root"
    ${pkgs.coreutils}/bin/chown -R root:lego "${cfg.home}/certificates-root"
  '';
in
{
  options = {
    ptsd.lego = {
      enable = mkEnableOption "lego with ACME DNS";
      home = mkOption {
        type = types.str;
        default = "/var/lib/lego";
      };
      domain = mkOption {
        type = types.str;
        example = "tp1.host.nerdworks.de";
      };
      extraDomains = mkOption {
        type = with types; listOf str;
        default = [];
      };
      server = mkOption {
        type = types.str;
        example = "https://acme-staging-v02.api.letsencrypt.org/directory";
        default = "https://acme-v02.api.letsencrypt.org/directory";
      };
      dnsResolvers = mkOption {
        type = with types; listOf str;
        default = [ "8.8.8.8" "8.8.4.4" ];
      };
      acmeDnsApiBase = mkOption {
        type = types.str;
        default = "https://auth.nerdworks.de";
      };
      email = mkOption {
        type = types.str;
        default = "elo-lenc@nerdworks.de";
      };
    };
  };

  config = mkIf cfg.enable {

    users.groups.lego = {};
    users.users.lego = {
      group = "lego";
      home = cfg.home;
      createHome = true;
      isSystemUser = true;
    };

    systemd.services."lego" = {
      description = "lego Let's Encrypt client";
      after = [ "network.target" "network-online.target" ];
      requires = [ "network-online.target" ];

      # if the certificate file exists, try to renew it
      # if not, try to obtain a new certificate
      script = ''
        if [ -f "${cfg.home}/certificates/${cfg.domain}.crt" ]; then
            ${pkgs.lego}/bin/lego \
            --server="${cfg.server}" \
            --email=${cfg.email} \
            --domains="${cfg.domain}" \
            ${concatMapStrings (extraDomain: "--domains=\"${extraDomain}\" ") cfg.extraDomains} \
            --dns=acme-dns \
            ${concatMapStrings (dnsResolver: "--dns.resolvers=\"${dnsResolver}\" ") cfg.dnsResolvers} \
            --path="${cfg.home}" \
            --accept-tos \
            renew --days 30
        else            
            ${pkgs.lego}/bin/lego \
            --server="${cfg.server}" \
            --email=${cfg.email} \
            --domains="${cfg.domain}" \
            ${concatMapStrings (extraDomain: "--domains=\"${extraDomain}\" ") cfg.extraDomains} \
            --dns=acme-dns \
            ${concatMapStrings (dnsResolver: "--dns.resolvers=\"${dnsResolver}\" ") cfg.dnsResolvers} \
            --path="${cfg.home}" \
            --accept-tos \
            run
        fi
      '';
      serviceConfig = {
        User = "lego";
        Group = "lego";
        ProtectHome = true;
        ProtectSystem = "full";
        Restart = "on-failure";
        RestartSec = "10min";

        ExecStartPost = ''+${unit-script-post}/bin/unit-script-lego-post'';
      };
      environment = {
        ACME_DNS_STORAGE_PATH = "${cfg.home}/acme-dns-store.json";
        ACME_DNS_API_BASE = "${cfg.acmeDnsApiBase}";
      };
      startAt = "*-*-* 06:00:00";
    };

    # use this e.g. when adding extraDomains
    systemd.services."lego-force-run" = {
      description = "lego Let's Encrypt client - Force 'lego run'";
      after = [ "network.target" "network-online.target" ];
      requires = [ "network-online.target" ];

      script = ''
        ${pkgs.lego}/bin/lego \
        --server="${cfg.server}" \
        --email=${cfg.email} \
        --domains="${cfg.domain}" \
        ${concatMapStrings (extraDomain: "--domains=\"${extraDomain}\" ") cfg.extraDomains} \
        --dns=acme-dns \
        ${concatMapStrings (dnsResolver: "--dns.resolvers=\"${dnsResolver}\" ") cfg.dnsResolvers} \
        --path="${cfg.home}" \
        --accept-tos \
        run
      '';
      serviceConfig = {
        User = "lego";
        Group = "lego";
        ProtectHome = true;
        ProtectSystem = "full";
        Type = "oneshot";

        ExecStartPost = ''+${unit-script-post}/bin/unit-script-lego-post'';
      };
      environment = {
        ACME_DNS_STORAGE_PATH = "${cfg.home}/acme-dns-store.json";
        ACME_DNS_API_BASE = "${cfg.acmeDnsApiBase}";
      };
    };
  };

}
