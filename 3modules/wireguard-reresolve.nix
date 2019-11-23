{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.networking.wireguard;

  generateUnit = name: values:
    nameValuePair "wireguard-${name}-reresolve"
      {
        description = "Reresolve WireGuard Tunnel - ${name}";
        requires = [ "network-online.target" ];
        after = [ "network.target" "network-online.target" ];
        path = with pkgs; [ wireguard-tools ];

        # from https://git.zx2c4.com/WireGuard/tree/contrib/examples/reresolve-dns/reresolve-dns.sh
        # WARNING: nixpkgs-fmt might remove *necessary* spaces!!! Be cautious.
        script = ''
          INTERFACE="${name}"

          reset_peer_section() {
            PUBLIC_KEY=""
            ENDPOINT=""
          }

          process_peer() {
            [[ -z $PUBLIC_KEY || -z $ENDPOINT ]] && return 0
            [[ $(wg show "$INTERFACE" latest-handshakes) =~ ^''${PUBLIC_KEY//+/\\+}\	([0-9]+)$ ]] || return 0
            (( ($(date +%s) - ''${BASH_REMATCH[1]}) > 135 )) || return 0
            wg set "$INTERFACE" peer "$PUBLIC_KEY" endpoint "$ENDPOINT"
            echo reloaded endpoint for peer $PUBLIC_KEY
            reset_peer_section
          }

          ${concatMapStringsSep "\n" (
          peer: ''
            PUBLIC_KEY="${peer.publicKey}"
            ENDPOINT="${peer.endpoint}"
            process_peer;
          ''
        ) values.peers}
        '';

        startAt = "minutely";
      };

in
{
  options = {
    networking.wireguard.reresolve = mkOption {
      example = [ "wg1" ];
      default = [];
      type = with types; listOf str;
      description = "List of interface names to reresolve";
    };
  };

  config = {

    # only generate units mentioned in cfg.rereseolve
    systemd.services = mapAttrs' generateUnit (filterAttrs (n: v: any (x: x == n) cfg.reresolve) cfg.interfaces);

  };

}
