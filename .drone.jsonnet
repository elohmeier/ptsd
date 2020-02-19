local Deploy(hostname, populate_unstable) = {
  name: "deploy " + hostname,
  commands: [
    "eval $(ssh-agent -s)",
    @"echo ""$SSH_KEY"" | tr -d '\r' | ssh-add -",
    "$(nix-build --no-out-link krops.nix --argstr name " + hostname + " --arg secrets false --arg unstable " + populate_unstable + " -A deploy -I /var/src)"
  ],
  environment: {
    SSH_KEY: {
      from_secret: "ssh-key"
    }
  }
};

[
  {
    kind: "pipeline",
    type: "exec",
    name: "default",

    steps : [
      {
        name: "submodules",
        commands: [
          "git submodule update --init --recursive --remote"
        ]
      },
      #{
      #  name: "build",
      #  commands: [
      #    "nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/smtp-to-telegram {}' -I /var/src"
      #  ]
      #},
      Deploy("apu1", false),
      Deploy("htz1", true),
      Deploy("htz2", false),
      Deploy("nas1", false),
      Deploy("nuc1", false)
    ]
  }
]
