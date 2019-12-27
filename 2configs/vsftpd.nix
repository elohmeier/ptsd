{ config, pkgs, ... }:

{
  services.vsftpd = {
    enable = true;
    forceLocalLoginsSSL = true;
    forceLocalDataSSL = true;
    userlistDeny = false;
    localUsers = true;
    rsaKeyFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.key";
    rsaCertFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.crt";
    userlist = [ config.users.users.mainUser.name ];
    extraConfig = ''
      pasv_enable=Yes
      pasv_min_port=10090
      pasv_max_port=10100
    '';
    writeEnable = true;
  };
  networking.firewall.allowedTCPPorts = [ 21 ];
  networking.firewall.allowedTCPPortRanges = [
    { from = 10090; to = 10100; }
  ];
}
