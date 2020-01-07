HOST=$(shell hostname)

.PHONY: local
local:
	$$(nix-build --no-out-link krops.nix --argstr name $(HOST) -A populate)
	sudo nixos-rebuild build -I /var/src


# https://discourse.drone.io/t/porting-matrix-builds-to-1-0-multi-machine-pipelines/2966
.drone.yml: .drone.jsonnet
	drone jsonnet --stream

.PHONY: pretty
pretty:
	nixpkgs-fmt 1systems
	nixpkgs-fmt 2configs
	find 3modules -name '*.nix' ! -name 'wireguard-reresolve.nix' -exec nixpkgs-fmt {} \;
	nixpkgs-fmt 4lib
	nixpkgs-fmt 5pkgs
	nixpkgs-fmt lib
	nixpkgs-fmt *.nix

.PHONY: eee1
eee1:
	sudo nix-build '<nixpkgs/nixos>' -A system -I nixos-config=1systems/eee1/physical.nix -I secrets=/var/src/secrets-eee1 -I /var/src --argstr system i686-linux
