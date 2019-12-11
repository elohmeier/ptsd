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
	nixpkgs-fmt .
