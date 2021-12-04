{ config, lib, pkgs, ... }:

with lib;
let
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
  systemd.services.vsftpd = {
    description = "Vsftpd Server";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "@${pkgs.vsftpd}/sbin/vsftpd vsftpd ${configFile}";
      Restart = "always";
      Type = "forking";
    };
  };

  ptsd.secrets.files."vsftpd-logins.db" = {
    dependants = [ "vsftpd.service" ];
  };

  security.pam.services.vsftpd.text = ''
    auth required pam_userdb.so db=${builtins.replaceStrings [".db"] [""] config.ptsd.secrets.files."vsftpd-logins.db".path}
    account required pam_userdb.so db=${builtins.replaceStrings [".db"] [""] config.ptsd.secrets.files."vsftpd-logins.db".path}
  '';

  networking.firewall.interfaces.br0.allowedTCPPorts = [ 21 ];
  networking.firewall.interfaces.br0.allowedTCPPortRanges = [
    { from = cfg.pasv_min_port; to = cfg.pasv_max_port; }
  ];

  users.users.vsftpd = {
    description = "VSFTPD user";
    home = "/homeless-shelter";
    isSystemUser = true;
    group = "vsftpd";
  };
  users.groups.vsftpd = { };
}
