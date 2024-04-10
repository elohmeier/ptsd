{ inputs, ... }:
{
  perSystem = { pkgs, system, ... }: {
    devShells.default =
      pkgs.mkShellNoCC {
        packages = [
          pkgs.checkSSLCert
          pkgs.dig
          pkgs.hash-slinger
        ];
      };
  };
}
