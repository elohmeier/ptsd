_:
{
  imports = [
    ./acme-dns.nix
    ./alerta.nix
    ./dlrg-vpn-client.nix
    ./dlrg-vpn-host.nix
    ./docker-home-assistant.nix
    ./drone-server.nix
    ./gitea.nix
    ./lego.nix
    ./nwbackup.nix
    ./nwbackup-server.nix
    ./nwmonit.nix
    ./nwstats.nix
    ./nwtelegraf.nix
    ./nwtraefik.nix
    ./nwvpn.nix
    ./nwvpn-server.nix
    ./radicale.nix
    ./secrets.nix
    ./traefik-forward-auth.nix
    ./vdi-container.nix
    ./wireguard-reresolve.nix
  ];
}
