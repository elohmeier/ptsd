# ptsd

[![Build Status](https://ci.nerdworks.de/api/badges/nerdworks/ptsd/status.svg)](https://ci.nerdworks.de/nerdworks/ptsd)

Public [Nix](https://nixos.org/nix/) configurations.


## Setup

Add the ptsd channel using

```console
$ nix-channel --add https://git.nerdworks.de/nerdworks/ptsd/archive/master.tar.gz ptsd
$ nix-channel --update
```


## Cachix

To use the binary cache select a supported channel as the "nixpkgs" channel.

Supported channels:
* https://nixos.org/channels/nixos-19.09
* https://nixos.org/channels/nixos-unstable

Use [Cachix](https://cachix.org/) to enable the binary cache by invoking 
`cachix use nerdworks` (or `nix-shell -p cachix --run "cachix use nerdworks"`).

