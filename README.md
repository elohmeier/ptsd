# ptsd

[![Build Status](https://ci.nerdworks.de/api/badges/nerdworks/ptsd/status.svg)](https://ci.nerdworks.de/nerdworks/ptsd)

Public [Nix](https://nixos.org/nix/) configurations.


## Setup

Add the ptsd channel using

```console
$ nix-channel --add https://git.nerdworks.de/nerdworks/ptsd/archive/master.tar.gz ptsd
$ nix-channel --update
```

## Hacking on ptsd

Make sure to remove the ptsd channel first to avoid conflicts.
Then include local checkout of ptsd in nix builds by altering the NIX\_PATH variable.

E.g. to use local checkout in home-manager:

```console
NIX_PATH=$NIX_PATH:ptsd=$HOME/ptsd home-manager build
```

or when rebuilding using sudo:

```console
sudo nixos-rebuild -I ptsd=$HOME/ptsd build
```


## Cachix

To use the binary cache select a supported channel as the "nixpkgs" channel.

Supported channels:
* https://nixos.org/channels/nixos-19.09
* https://nixos.org/channels/nixos-unstable

Use [Cachix](https://cachix.org/) to enable the binary cache by invoking 
`cachix use nerdworks` (or `nix-shell -p cachix --run "cachix use nerdworks"`).


## Remote Installation via SSH

1. `make iso` and `dd` to USB stick.
2. Boot from stick and connect via SSH (e.g. via torsocks).
3. Prepare installation FS and mount to `/mnt`.
3. Populate target using `$(nix-build --no-out-link krops.nix --argstr name HOSTNAME --argstr starget "root@IP/mnt/var/src" --arg desktop true -A populate)`.
4. Build system remotely using `nix-build -I nixos-config=/mnt/var/src/ptsd/1systems/HOST/physical.nix -I /mnt/var/src/ '<nixpkgs/nixos>' -A system --no-out-link --store /mnt`.
5. Install the system using `nixos-install --system /nix/store/... --no-root-passwd`.
6. Unmount everything and reboot.
