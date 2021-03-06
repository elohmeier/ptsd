{ config, lib, pkgs, ... }:
{
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };


  services.unbound = {
    enable = true;
    allowedAccess = [ "192.168.178.0/24" ];
    interfaces = [ "192.168.178.11" ];

    # TODO: Generate local entries
    # The first two lines are in the "server:" context of the generated cfg
    extraConfig = ''
      #  private-domain: "host.nerdworks.de"
      #  domain-insecure: "host.nerdworks.de"

      include: /var/lib/unbound/blocklist.conf

      # entry is set on main NS to local IP, no override necessary
      # changed for DNSSEC
      #local-data: "prt1 A 192.168.178.33"
      #local-data: "prt1.host.nerdworks.de A 192.168.178.33"

      # disabled for DNSSEC
      #local-data: "apu1 A 192.168.178.11"
      #local-data: "apu1.host.nerdworks.de A 192.168.178.11"

      #local-data: "nas1 A 192.168.178.12"
      #local-data: "nas1.host.nerdworks.de A 192.168.178.12"

      #local-data: "nuc1 A 192.168.178.10"
      #local-data: "nuc1.host.nerdworks.de A 192.168.178.10"

      remote-control:
        control-enable: yes
        server-key-file: "/var/lib/unbound/unbound_server.key"
        server-cert-file: "/var/lib/unbound/unbound_server.pem"
        control-key-file: "/var/lib/unbound/unbound_control.key"
        control-cert-file: "/var/lib/unbound/unbound_control.pem"
    '';
  };

  environment.systemPackages = [ pkgs.openssl ]; # openssl required for unbound-control-setup utility

  # as of 2019-12-08 not possible, since telegraf input plugin
  # supports no extra -c /var/lib/unbound/unbound.conf argument for
  # non-default configurations (as in NixOS).
  # waiting for https://github.com/influxdata/telegraf/pull/6770
  #  ptsd.nwtelegraf.extraConfig = {
  #    inputs.unbound = {
  #      server =  "127.0.0.1:8953";
  #      binary = "${pkgs.unbound}/bin/unbound-control";
  #      thread_as_tag = true;
  #    };
  #  };

  # init unbound remote-control using:
  # 1. sudo unbound-control-setup -d /var/lib/unbound/
  # 2. sudo chown unbound /var/lib/unbound/*.key
  # 3. sudo chown unbound /var/lib/unbound/*.pem

  systemd.services.update-unbound-blocklist = {
    description = "Update the unbound blocklist hosts file";
    wants = [ "network.target" "network-online.target" ];
    after = [ "network.target" "network-online.target" ];
    startAt = "daily";

    script = ''
      set -e
      ${pkgs.curl}/bin/curl -SsL https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | \
        ${pkgs.gnugrep}/bin/grep '^0\.0\.0\.0' | \
        ${pkgs.gawk}/bin/awk '{print "local-zone: \""$2"\" always_nxdomain"}' \
        > /var/lib/unbound/blocklist.conf

      ${pkgs.unbound}/bin/unbound-control -c /var/lib/unbound/unbound.conf reload
    '';

    serviceConfig = {
      User = "unbound";
    };
  };

}
