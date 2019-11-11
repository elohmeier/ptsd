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

