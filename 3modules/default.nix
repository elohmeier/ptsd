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
    ./maddy.nix
    ./mautrix-whatsapp.nix
    ./mjpg-streamer.nix
    ./monica.nix
    ./mosquitto.nix
    ./navidrome.nix
    ./nwacme.nix
    ./nwbackup.nix
    ./nwbackup-server.nix
    ./nwbitwarden.nix
    ./nwlogrotate.nix
    ./nwsyncthing.nix
    ./nwtraefik.nix
    ./octoprint.nix
    ./photoprism.nix
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
