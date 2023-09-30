{ self, lib, withSystem, ... }:
let
  nixosSystemFor = system: modules:
    let
      pkgs = withSystem system ({ pkgs, ... }: pkgs);
    in
    lib.nixosSystem {
      inherit system;
      specialArgs = { inherit lib; };
      modules = [
        {
          _module.args = {
            pkgs = lib.mkForce pkgs;
          };
        }
        self.nixosModules.secrets
        self.nixosModules.tailscale
        self.nixosModules.wireguard
        self.nixosModules.ports
      ] ++ modules;
    };

in
{
  flake.nixosModules = {
    borgbackup = ./borgbackup.nix;
    defaults = ./defaults.nix;
    dradis = ./dradis.nix;
    hcloud = ./hcloud;
    host-htz1 = ./hosts/htz1;
    hw-hetzner-vm = ./hw/hetzner-vm.nix;
    luks-ssh-unlock = ./luks-ssh-unlock.nix;
    nix-presistent = ./nix-persistent.nix;
    nwhost = ./nwhost.nix;
    prometheus-node = ./prometheus-node.nix;
    secrets = ./secrets.nix;
    tailscale = ./tailscale.nix;
    wireguard = ./wireguard.nix;
    ports = ./ports.nix;
  };

  flake.nixosConfigurations = {
    lene-gotthard-striebitz = nixosSystemFor "aarch64-linux" [
      self.nixosModules.hcloud
      self.nixosModules.dradis
      { _module.args.nixinate = { host = "128.140.113.13"; sshUser = "root"; buildOn = "remote"; }; }
    ];

    htz1 = nixosSystemFor "x86_64-linux" [
      self.nixosModules.borgbackup
      self.nixosModules.defaults
      self.nixosModules.host-htz1
      self.nixosModules.hw-hetzner-vm
      self.nixosModules.luks-ssh-unlock
      self.nixosModules.nix-presistent
      self.nixosModules.nwhost
      self.nixosModules.prometheus-node
      { _module.args.nixinate = { host = "htz1.nn42.de"; sshUser = "root"; buildOn = "remote"; }; }
    ];
  };
}


