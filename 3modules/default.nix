_:
{
  imports = [
    ./dlrg-vpn-client.nix
    ./dlrg-vpn-host.nix
    ./docker-home-assistant.nix
    ./lego.nix
    ./nwbackup.nix
    ./nwmonit.nix
    ./nwtelegraf.nix
    ./nwvpn.nix
    ./vdi-container.nix
    ./wireguard-reresolve.nix
  ];
}
