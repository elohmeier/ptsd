# ptsd

Public [Nix](https://nixos.org/nix/) configurations.


## Cachix

To use the binary cache select [nixos-19.09](https://nixos.org/channels/nixos-19.09) as
the "nixpkgs" channel.

Then use [Cachix](https://cachix.org/) to enable the cache by invoking 
`cachix use nerdworks` or `nix-shell -p cachix --run "cachix use nerdworks"`.

