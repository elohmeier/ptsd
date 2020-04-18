{ config, lib, pkgs, ... }:

let
  fqdn = "htz2.host.nerdworks.de"; # has reverse DNS
in
{
  imports = [
    <nixos-mailserver>
  ];

  mailserver = {
    enable = true;
    fqdn = fqdn;
    domains = [ "nerdworks.de" "nerd-works.de" ];

    loginAccounts = {};

    certificateScheme = 1;
    certificateFile = "${config.ptsd.lego.home}/certificates/${config.networking.hostName}.${config.networking.domain}.crt";
    keyFile = "${config.ptsd.lego.home}/certificates/${config.networking.hostName}.${config.networking.domain}.key";

    backup.enable = true; # backup via rsnapshot

    virusScanning = false;
  };

  ptsd.nwmonit.extraConfig = [
    ''
      check process postfix matching "${pkgs.postfix}/libexec/postfix/master"
        start program = "${pkgs.systemd}/bin/systemctl start postfix"
        stop program = "${pkgs.systemd}/bin/systemctl stop postfix"
        if failed host ${fqdn} port 25 protocol smtp for 5 cycles then restart

      check process dovecot with pidfile /var/run/dovecot2/master.pid
        start program = "${pkgs.systemd}/bin/systemctl start dovecot2"
        stop program = "${pkgs.systemd}/bin/systemctl stop dovecot2"
        if failed host ${fqdn} port 143 protocol imap for 5 cycles then restart

      check process rspamd matching "rspamd: main process"
        start program = "${pkgs.systemd}/bin/systemctl start rspamd"
        stop program = "${pkgs.systemd}/bin/systemctl stop rspamd"
    ''
  ];

}
