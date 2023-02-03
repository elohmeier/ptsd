{ ... }:

{
  imports = [
    ./alertmanager.nix
    ./blackbox-exporter.nix
    ./checktlsa.nix
    #./fritzbox-exporter.nix
    ./grafana.nix
    ./pushgateway.nix
    #./quotes-exporter.nix
    ./server.nix
  ];
}
