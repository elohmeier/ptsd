{
  # speed-up borg backup and other service
  networking = {
    hosts = {
      "192.168.178.10" = [ "nuc1.host.nerdworks.de" "nuc1" ];
      "192.168.178.11" = [ "apu1.host.nerdworks.de" "apu1" ];
      "192.168.178.12" = [ "nas1.host.nerdworks.de" "nas1" ];
      "192.168.178.33" = [ "prt1.host.nerdworks.de" "prt1" ];
    };
  };
}
