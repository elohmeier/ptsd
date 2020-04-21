local FetchSubmodules() = {
  name: "fetch submodules",
  commands: [
    "git submodule update --init --recursive --remote"
  ]
};

local Deploy(hostname, populate_unstable, populate_mailserver) = {
  name: "deploy " + hostname,
  commands: [
    "eval $(ssh-agent -s)",
    @"echo ""$SSH_KEY"" | tr -d '\r' | ssh-add -",
    "$(nix-build --no-out-link krops.nix --argstr name " + hostname + " --arg secrets false --arg unstable " + populate_unstable + " --arg mailserver " + populate_mailserver + " -A deploy -I /var/src)"
  ],
  environment: {
    SSH_KEY: {
      from_secret: "ssh-key"
    }
  }
};

local DeployPipeline(hostname, populate_unstable=false, populate_mailserver=false, prebuild_hass=false) = {
  kind: "pipeline",
  type: "exec",
  name: "deploy " + hostname,

  steps : (
    if prebuild_hass then [
      {
        name: "prebuild hass",
        commands: [
          "nix-copy-closure --to root@" + hostname + " $(nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/nwhass {}' -I /var/src)"
        ]
      }
    ] else []
  ) + [
    FetchSubmodules(),
    Deploy(hostname, populate_unstable, populate_mailserver)
  ]
};

[
  //DeployPipeline("apu1"),
  DeployPipeline("apu2", prebuild_hass=true),
  DeployPipeline("htz1", populate_unstable=true),
  DeployPipeline("htz2", populate_unstable=true, populate_mailserver=true),
  DeployPipeline("nas1", prebuild_hass=true),
  //DeployPipeline("nuc1"),
  DeployPipeline("rpi2"),
  DeployPipeline("ws1", populate_unstable=true)
]

# Don't forget to run `make .drone.yml`
