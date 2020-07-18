{ config, lib, pkgs, ... }:

with lib;
let
  lanDomain = "lan.nerdworks.de";
  universe = import <ptsd/2configs/universe.nix>;

  cups-tls =
    pkgs.runCommand "cups-tls"
      { } ''
      mkdir -p $out
      ln -s "/var/lib/acme/${config.networking.hostName}.${config.networking.domain}/fullchain.pem" "$out/${config.networking.hostName}.${config.networking.domain}.crt"
      ln -s "/var/lib/acme/${config.networking.hostName}.${config.networking.domain}/key.pem" "$out/${config.networking.hostName}.${config.networking.domain}.key"  
    '';
in
{
  users.groups.certs.members = [ "cups" ];

  security.acme.certs."${config.networking.hostName}.${config.networking.domain}" = {
    extraDomains = { "${config.networking.hostName}.${lanDomain}" = null; };
    postRun = "systemctl restart cups.service";
  };

  services.printing = {
    enable = true;
    browsing = true;
    defaultShared = true;
    drivers = with pkgs; [ brlaser ];
    startWhenNeeded = false;
    listenAddresses = [ "${universe.hosts."${config.networking.hostName}".nets.bs53lan.ip4.addr}:631" ];
    # allowFrom = [ "all" ]; # TODO: uncomment & delete local file in 20.09 (https://github.com/NixOS/nixpkgs/pull/86013)
    extraFilesConf = ''
      CreateSelfSignedCerts no
      ServerKeychain ${cups-tls}
    '';
  };

  networking.firewall.interfaces.br0 = {
    allowedTCPPorts = [ 631 ];
    allowedUDPPorts = [ 631 ];
  };

  services.avahi = {
    enable = true;

    publish = {
      enable = true;
      userServices = true;
    };

    # Generated using https://github.com/jpawlowski/airprint-generate
    # see https://github.com/NixOS/nixpkgs/issues/13901
    # and don't run into https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=882386
    extraServiceFiles = {
      "mfc7440" = ''
        <?xml version='1.0' encoding='UTF-8'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">Sec.AirPrint MFC7440N @ %h</name>
          <service>
            <type>_ipps._tcp</type>
            <subtype>_universal._sub._ipps._tcp</subtype>
            <port>631</port>
            <txt-record>txtvers=1</txt-record>
            <txt-record>qtotal=1</txt-record>
            <txt-record>Transparent=T</txt-record>
            <txt-record>URF=DM3</txt-record>
            <txt-record>TLS=1.2</txt-record>
            <txt-record>printer-state=3</txt-record>
            <txt-record>product=(GPL Ghostscript)</txt-record>
            <txt-record>pdl=application/octet-stream,application/pdf,application/postscript,application/vnd.cups-raster,image/gif,image/jpeg,image/png,image/tiff,image/urf,text/html,text/plain,application/vnd.adobe-reader-postscript,application/vnd.cups-pdf</txt-record>
            <txt-record>rp=printers/MFC7440N</txt-record>
            <txt-record>printer-type=0x1044</txt-record>
            <txt-record>ty=Brother MFC-7360N, using brlaser v4</txt-record>
            <txt-record>adminurl=ipps://${config.networking.hostName}.${lanDomain}/printers/MFC7440N</txt-record>
          </service>
        </service-group>
      '';
    };

    nssmdns = true;
  };
}
