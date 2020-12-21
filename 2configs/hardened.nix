{ ... }:
{
  imports = [
    <nixpkgs/nixos/modules/profiles/hardened.nix>
  ];

  boot.kernel.sysctl = {
    "kernel.dmesg_restrict" = true;
  };
}
