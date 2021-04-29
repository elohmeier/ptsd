_:
{
  imports = [
    ./acme-dns.nix
    ./alertmanager-bot.nix
    #./cli.nix  # prevent pulling in where no home-manager is present
    ./cups-airprint.nix
    #./desktop.nix  # prevent pulling in where no home-manager is present
    ./drone-server.nix
    ./fraamdb.nix
    ./fraam-gitlab.nix
    ./fraam-www.nix
    ./mjpg-streamer.nix
    ./monica.nix
    ./mosquitto.nix
    ./nwacme.nix
    ./nwbackup.nix
    ./nwbackup-server.nix
    ./nwbitwarden.nix
    ./nwlogrotate.nix
    ./nwsyncthing.nix
    ./nwtraefik.nix
    ./octoprint.nix
    ./pulseaudio.nix
    ./radicale.nix
    ./samba-sonos.nix
    ./secrets.nix
    ./traefik-forward-auth.nix
    ./traggo.nix
    ./vdi-container.nix
    ./wireguard.nix
    ./xrdp.nix
  ];
}
