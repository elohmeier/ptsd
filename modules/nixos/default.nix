{
  self,
  inputs,
  lib,
  withSystem,
  ...
}:
let
  nixosSystemFor =
    system: modules:
    let
      pkgs = withSystem system ({ pkgs, ... }: pkgs);
    in
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit lib;
      };
      modules = [
        {
          _module.args = {
            pkgs = lib.mkForce pkgs;
          };

          nix.settings.extra-nix-path = "nixpkgs=flake:${inputs.nixpkgs}";
        }
        self.nixosModules.ports
        self.nixosModules.tailscale
      ] ++ modules;
    };
in
{
  flake.nixosModules = {
    borgbackup = ./borgbackup.nix;
    defaults = ./defaults.nix;
    fish = ./fish.nix;
    generic = ./generic.nix;
    generic-desktop = ./generic-desktop.nix;
    generic-disk = ./generic-disk.nix;
    hcloud = ./hcloud;
    host-htz1 = ./hosts/htz1;
    host-htz2 = ./hosts/htz2;
    hw-hetzner-vm = ./hw/hetzner-vm.nix;
    luks-ssh-unlock = ./luks-ssh-unlock.nix;
    mainuser = ./users/mainuser.nix;
    networkmanager = ./networkmanager.nix;
    nix-persistent = ./nix-persistent.nix;
    nwhost = ./nwhost.nix;
    orbstack-defaults = ./orbstack-defaults/default.nix;
    ports = ./ports.nix;
    prometheus-node = ./prometheus-node.nix;
    tailscale = ./tailscale.nix;
    tp4 = ./tp4.nix;
    users = ./users;
    utmvm-nixos-3 = ./utmvm-nixos-3.nix;
  };

  flake.diskoConfigurations = {
    tp3 = import ./tp3/modules/disko.nix;
  };

  flake.nixosConfigurations = {
    # htz1 = nixosSystemFor "x86_64-linux" [
    #   self.nixosModules.borgbackup
    #   self.nixosModules.defaults
    #   self.nixosModules.host-htz1
    #   self.nixosModules.hw-hetzner-vm
    #   self.nixosModules.luks-ssh-unlock
    #   self.nixosModules.nix-persistent
    #   self.nixosModules.nwhost
    #   self.nixosModules.prometheus-node
    # ];

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

    # utmvm_nixos_3 = nixosSystemFor "aarch64-linux" [
    #   inputs.nix95.nixosModules.nix95
    #   self.nixosModules.defaults
    #   self.nixosModules.fish
    #   self.nixosModules.generic
    #   self.nixosModules.generic-disk
    #   self.nixosModules.mainuser
    #   self.nixosModules.nix-persistent
    #   self.nixosModules.utmvm-nixos-3
    # ];

    # sudo systemd-cryptenroll --tpm2-device=/dev/tpmrm0 --tpm2-pcrs=0+7 /dev/nvme0n1p2
    tp3 = nixosSystemFor "x86_64-linux" [
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModule
      inputs.nix95.nixosModules.nix95
      inputs.sops-nix.nixosModules.default
      self.nixosModules.defaults
      self.nixosModules.networkmanager
      self.nixosModules.tailscale
      self.nixosModules.users
      ./tp3
    ];

    # build using `NIX_CONFIG="extra-experimental-features = nix-command flakes" nix shell nixpkgs#git --command nix build /Users/enno/repos/ptsd#nixosConfigurations.orb-nixos.config.system.build.topLevel -L`
    # activate using `NIX_CONFIG="extra-experimental-features = nix-command flakes" nix shell nixpkgs#git --command nixos-rebuild --flake /Users/enno/repos/ptsd#orb-nixos --use-remote-sudo switch`
    orb-nixos = nixosSystemFor "aarch64-linux" [
      self.nixosModules.defaults
      self.nixosModules.orbstack-defaults
      (
        { pkgs, ... }:
        {
          networking.hostName = "nixos";
          users.defaultUserShell = pkgs.fish;
          programs.fish.enable = true;
          nix.settings.trusted-users = [
            "root"
            "enno"
          ];
        }
      )
    ];

    orb-nixos-builder = nixosSystemFor "aarch64-linux" [
      self.nixosModules.defaults
      self.nixosModules.orbstack-defaults
      ./orbstack-builder.nix
    ];
  };
}
