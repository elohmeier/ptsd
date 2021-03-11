self: super:
with super.lib;
let
  eq = x: y: x == y;
  subdirsOf = path:
    mapAttrs
      (name: _: path + "/${name}")
      (filterAttrs (_: eq "directory") (builtins.readDir path));
in
mapAttrs
  (_: flip self.callPackage { })
  (
    filterAttrs
      (_: dir: pathExists (dir + "/default.nix"))
      (subdirsOf ./.)
  )
  // {
  # From https://github.com/t184256/nix-on-droid/wiki/Use-a-remote-builder-with-qemu
  qemu-user-arm =
    if self.stdenv.system == "x86_64-linux"
    then self.pkgsi686Linux.callPackage ../6cipkgs/qemu { user_arch = "arm"; }
    else self.callPackage ../6cipkgs/qemu { user_arch = "arm"; };
  qemu-user-x86 = self.callPackage ../6cipkgs/qemu { user_arch = "x86_64"; };
  qemu-user-arm64 = self.callPackage ../6cipkgs/qemu { user_arch = "aarch64"; };
  qemu-user-riscv32 = self.callPackage ../6cipkgs/qemu { user_arch = "riscv32"; };
  qemu-user-riscv64 = self.callPackage ../6cipkgs/qemu { user_arch = "riscv64"; };
}
# left for illustrative purposes
#  // {
# inherit (self.callPackage ./hasura {})
#   hasura-cli
#   hasura-graphql-engine
# };
