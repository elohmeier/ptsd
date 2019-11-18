local Pipeline(pkg, channel) = {
  kind: "pipeline",
  type: "docker",
  name: "cachix:"+pkg+":"+channel,
  steps: [
    {
      name: "cachix:"+pkg+":"+channel,
      image: "nixos/nix",
      commands: [
        "nix-channel --add https://nixos.org/channels/"+channel+" nixpkgs",
        "nix-channel --update",
        "nix-env -i cachix",
        "nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/"+pkg+" {}' | cachix push nerdworks"
      ],
      environment: {
        CACHIX_SIGNING_KEY: {
          from_secret: "cachix-signing-key"
        }
      }
    }
  ]
};

[
  Pipeline("burrow", "nixos-19.09"),
  Pipeline("burrow", "nixos-unstable")
#  Pipeline("vim-customized", "nixos-19.09"),
#  Pipeline("vim-customized", "nixos-unstable")
]

