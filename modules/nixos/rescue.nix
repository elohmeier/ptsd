{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/netboot/netboot.nix"
    "${modulesPath}/profiles/minimal.nix"
  ];

  environment.defaultPackages = lib.mkForce [ ];

  users.users.root.openssh.authorizedKeys.keys =
    let
      sshPubKeys = import ./users/ssh-pubkeys.nix;
    in
    sshPubKeys.authorizedKeys_enno;

  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
  networking.firewall.checkReversePath = "loose";

  services.tailscale.enable = true;

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    after = [
      "network-pre.target"
      "tailscale.service"
    ];
    wants = [
      "network-pre.target"
      "tailscale.service"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";

    script = ''
      echo "Authenticating with Tailscale ..."
      ${pkgs.tailscale}/bin/tailscale up --authkey KEY
    '';
  };
}
