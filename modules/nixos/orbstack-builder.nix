{
  lib,
  pkgs,
  ...
}:

let
  user = "builder";
in
{
  environment.systemPackages = with pkgs; [
    btop
    cntr # for use with breakpointHook
    gitMinimal # nix develop support
    nix-top
  ];

  networking.hostName = "nixos-builder";

  services.openssh = {
    enable = lib.mkForce true;
    ports = [ 31022 ];
  };

  documentation.enable = lib.mkForce false;

  nix.channel.enable = false;

  nix.settings = {
    auto-optimise-store = true;
    min-free = 1024 * 1024 * 1024;
    max-free = 3 * 1024 * 1024 * 1024;
    trusted-users = [ user ];
  };

  users.users."${user}" = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOtB32gQF96zxxtDazLlmFTZANch/2MNlU+2nmMos8cs builder@localhost"
    ];
  };
}
