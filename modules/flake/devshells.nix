{ ... }:
{
  perSystem =
    {
      lib,
      pkgs,
      system,
      ...
    }:
    {
      devShells.default = pkgs.mkShellNoCC {
        packages = [
          pkgs.checkSSLCert
          pkgs.dig
        ] ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.hash-slinger ];
      };
    };
}
