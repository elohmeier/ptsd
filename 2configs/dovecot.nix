{ config, lib, pkgs, ... }:

{
  users.groups.lego = {
    members = [ "dovecot2" ];
  };

  services.dovecot2 = {
    enable = true;
    extraConfig = ''
      # only listen on loopback interfaces
      listen = 127.0.0.1, ::1

      ssl = required
    '';
    mailLocation = "maildir:~/Maildir/%u:LAYOUT=fs:INBOX=~/Maildir/%u/Inbox"; # mbsync compatible
    sslServerCert = "${config.ptsd.lego.home}/certificates/${config.networking.hostName}.${config.networking.domain}.crt";
    sslServerKey = "${config.ptsd.lego.home}/certificates/${config.networking.hostName}.${config.networking.domain}.key";
  };
}
