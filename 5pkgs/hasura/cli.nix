{ buildGoPackage, hasura-graphql-engine }:

buildGoPackage rec {
  name = "hasura-${version}";
  version = hasura-graphql-engine.version;

  src = hasura-graphql-engine.src;

  goPackagePath = "github.com/hasura/graphql-engine";
  subPackages = [ "cli/cmd/hasura" ];

  # generated using dep2nix inside `cli` folder
  goDeps = ./deps.nix;

  buildFlagsArray = [
    ''-ldflags=
    -X github.com/hasura/graphql-engine/cli/version.BuildVersion=${version}
    -s
    -w
  ''
  ];

  postInstall = ''
    mkdir -p $out/share/{bash-completion/completions,zsh/site-functions}

    export HOME=$PWD
    $bin/bin/hasura completion bash > $out/share/bash-completion/completions/hasura
    $bin/bin/hasura completion zsh > $out/share/zsh/site-functions/_hasura
  '';

  meta = {
    inherit (hasura-graphql-engine.meta) license homepage maintainers;
    description = "Hasura GraphQL Engine CLI";
  };
}
