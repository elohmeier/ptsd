{ self, inputs, lib, withSystem, ... }:
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
        self.nixosModules.dradis
        self.nixosModules.ports
        self.nixosModules.secrets
        self.nixosModules.tailscale
        self.nixosModules.wireguard
      ] ++ modules;
    };
in
{
  flake.nixosModules = {
    borgbackup = ./borgbackup.nix;
    defaults = ./defaults.nix;
    dradis = ./dradis.nix;
    fish = ./fish.nix;
    generic = ./generic.nix;
    generic-desktop = ./generic-desktop.nix;
    generic-disk = ./generic-disk.nix;
    hcloud = ./hcloud;
    hl5380dn = ./hl5380dn.nix;
    host-htz1 = ./hosts/htz1;
    host-htz2 = ./hosts/htz2;
    hw-hetzner-vm = ./hw/hetzner-vm.nix;
    luks-ssh-unlock = ./luks-ssh-unlock.nix;
    mainuser = ./users/mainuser.nix;
    networkmanager = ./networkmanager.nix;
    nix-persistent = ./nix-persistent.nix;
    nwhost = ./nwhost.nix;
    ports = ./ports.nix;
    prometheus-node = ./prometheus-node.nix;
    secrets = ./secrets.nix;
    tailscale = ./tailscale.nix;
    tp3 = ./tp3.nix;
    tp4 = ./tp4.nix;
    users = ./users;
    utmvm-nixos-3 = ./utmvm-nixos-3.nix;
    wireguard = ./wireguard.nix;
    xfce95 = ./xfce95.nix;
  };

  flake.nixosConfigurations = {
    mato-oestrovsky-loos = nixosSystemFor "aarch64-linux" [
      self.nixosModules.hcloud
      { ptsd.dradis.enable = true; }
    ];

    htz1 = nixosSystemFor "x86_64-linux" [
      self.nixosModules.borgbackup
      self.nixosModules.defaults
      self.nixosModules.host-htz1
      self.nixosModules.hw-hetzner-vm
      self.nixosModules.luks-ssh-unlock
      self.nixosModules.nix-persistent
      self.nixosModules.nwhost
      self.nixosModules.prometheus-node
    ];

    htz2 = nixosSystemFor "x86_64-linux" [
      self.nixosModules.borgbackup
      self.nixosModules.defaults
      self.nixosModules.host-htz2
      self.nixosModules.hw-hetzner-vm
      self.nixosModules.luks-ssh-unlock
      self.nixosModules.nix-persistent
      self.nixosModules.nwhost
      self.nixosModules.prometheus-node
    ];

    utmvm_nixos_3 = nixosSystemFor "aarch64-linux" [
      self.nixosModules.defaults
      self.nixosModules.fish
      self.nixosModules.generic
      self.nixosModules.generic-disk
      self.nixosModules.mainuser
      self.nixosModules.nix-persistent
      self.nixosModules.secrets
      self.nixosModules.utmvm-nixos-3
      self.nixosModules.xfce95
    ];

    tp3 = nixosSystemFor "x86_64-linux" [
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModule
      inputs.lanzaboote.nixosModules.lanzaboote
      self.nixosModules.defaults
      self.nixosModules.hl5380dn
      self.nixosModules.networkmanager
      self.nixosModules.nix-persistent
      self.nixosModules.secrets
      self.nixosModules.tailscale
      self.nixosModules.tp3
      self.nixosModules.users
      self.nixosModules.wireguard
      self.nixosModules.xfce95
    ];
  };
}
