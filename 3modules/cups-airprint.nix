{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.cups-airprint;
  universe = import <ptsd/2configs/universe.nix>;
in
{
  options = {
    ptsd.cups-airprint = {
      enable = mkEnableOption "cups-airprint";
      lanDomain = mkOption
        {
          default = "lan.nerdworks.de";
          type = types.str;
        };
      listenAddress = mkOption {
        default = "${universe.hosts."${config.networking.hostName}".nets.bs53lan.ip4.addr}:631";
        type = types.str;
      };
      printerName = mkOption {
        default = "MFC7440N";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {

    services.printing = {
      enable = true;
      browsing = true;
      defaultShared = true;
      startWhenNeeded = false;
      listenAddresses = [ "127.0.0.1:631" "::1:631" cfg.listenAddress ];
      allowFrom = [ "all" ];
      # self-signed certificate works for AirPrint and will be accepted by iOS clients
      extraFilesConf = ''
        CreateSelfSignedCerts yes 
      '';
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
        "${toLower cfg.printerName}" = ''
          <?xml version='1.0' encoding='UTF-8'?>
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">Sec.AirPrint ${cfg.printerName} @ %h</name>
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
              <txt-record>rp=printers/${cfg.printerName}</txt-record>
              <txt-record>printer-type=0x1044</txt-record>
              <txt-record>ty=Brother MFC-7360N, using brlaser v4</txt-record>
              <txt-record>adminurl=ipps://${config.networking.hostName}.${cfg.lanDomain}/printers/${cfg.printerName}</txt-record>
            </service>
          </service-group>
        '';
      };

      nssmdns = true;
    };
  };
}
