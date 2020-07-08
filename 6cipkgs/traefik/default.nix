# TODO: remove this as soon as https://github.com/containous/traefik/issues/5197
# has landed in 1.7 release.

{ pkgs, }:

pkgs.traefik.overrideAttrs (
  oldAttrs: rec {
    version = "1.7-dev";
    src = pkgs.fetchFromGitHub {
      owner = "containous";
      repo = "traefik";
      rev = "fee89273a37f639ffc260983b0c3f8ff064570de";
      sha256 = "1jvqsnywbmasdmfiwq55ss53m8xljladmv6mv4mr58kzjhlr9550";
    };
  }
)
