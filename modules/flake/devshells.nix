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
          pkgs.nagiosPlugins.check_ssl_cert
          pkgs.dig
        ] ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.hash-slinger ];
      };
    };
}
