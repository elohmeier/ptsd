{ config, lib, pkgs, ... }:

with lib;
let
  # logins = pkgs.writeText "logins.txt" ''
  #   enno
  #   enno
  #   luisa
  #   luisa
  # '';
  logins = <secrets/vsftpd-logins.txt>;
  userDb = pkgs.runCommand "userDb.db"
    { preferLocalBuild = true; } ''
    ${pkgs.db}/bin/db_load -T -t hash -f ${logins} $out
  '';
  cfg = {
    allow_writeable_chroot = "yes";
    anonymous_enable = "no";
    background = "yes";
    chroot_local_user = "yes"; # important: prevent cwd to other dirs than local_root
    guest_enable = "yes";
    guest_username = "nextcloud";
    listen = "yes";
    local_enable = "yes";
    local_root = "/var/lib/nextcloud/data/$USER/files/Scans";
    nopriv_user = "vsftpd";
    pam_service_name = "vsftpd";
    pasv_enable = "yes";
    pasv_min_port = 10090;
    pasv_max_port = 10100;
    syslog_enable = "yes";
    seccomp_sandbox = "no";
    secure_chroot_dir = "/var/empty";
    user_sub_token = "$USER";
    virtual_use_local_privs = "yes";
    write_enable = "yes";
  };
  configFile = pkgs.writeText "vsftpd.conf" (
    generators.toKeyValue { } cfg
  );
in
{
  environment.etc."vsftpd/userDb.db".source = userDb;

  systemd.services.vsftpd = {
    description = "Vsftpd Server";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "@${pkgs.vsftpd}/sbin/vsftpd vsftpd ${configFile}";
      Restart = "always";
      Type = "forking";
    };
  };

  security.pam.services.vsftpd.text = ''
    auth required pam_userdb.so db=/etc/vsftpd/userDb
    account required pam_userdb.so db=/etc/vsftpd/userDb
  '';

  networking.firewall.interfaces.br0.allowedTCPPorts = [ 21 ];
  networking.firewall.interfaces.br0.allowedTCPPortRanges = [
    { from = cfg.pasv_min_port; to = cfg.pasv_max_port; }
  ];

  users.users.vsftpd = {
    uid = config.ids.uids.vsftpd;
    description = "VSFTPD user";
    home = "/homeless-shelter";
  };
}
