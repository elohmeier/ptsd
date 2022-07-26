return {
    parse("flake-module-vm", [[
{
  description = "$1";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      overlay = final: prev: { };

      # defaultPackage = forAllSystems (system: (import nixpkgs {
      #   inherit system;
      #   overlays = [ self.overlay ];
      # }).XXX);

      devShell = forAllSystems
        (system: (with (import nixpkgs { inherit system; });
        mkShell { buildInputs = with pkgs; [ ]; }));

      nixosModules.$1 = ({ config, lib, pkgs, ... }: with lib;
        let
          cfg = config.services.$1;
        in
        {
          options.services.$1 = {
            enable = mkEnableOption "services.$1";
          };

          config = mkIf cfg.enable {
            nixpkgs.overlays = [ self.overlay ];
          };
        });

      nixosConfigurations.prod-vm = nixpkgs.lib.nixosSystem {
        system = "${2|aarch64-linux,x86_64-linux|}";
        modules = [
          self.nixosModules.$1
          ({ config, lib, modulesPath, pkgs, ... }: {
            imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];
            virtualisation.forwardPorts = [
              { host.port = 9080; guest.port = 8000; }
            ];
            services.getty.autologinUser = lib.mkDefault "root";
            console.keyMap = "de-latin1";
            services.$1 = {
              enable = true;
            };
            networking.firewall.allowedTCPPorts = [ 8000 ];
            system.stateVersion = "22.05";
          })
        ];
      };
    };
}
]])
}
