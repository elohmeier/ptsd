{
  # configuration.nix and orbstack.nix were just copied without modifications from a fresh NixOS 24.05 OrbStack Machine
  # lxd.nix is left empty (only contains the hostname, which we set elsewhere)
  imports = [
    ./configuration.nix
  ];
}
