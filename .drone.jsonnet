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

local DeployPipeline(hostname, populate_unstable, populate_mailserver) = {
  kind: "pipeline",
  type: "exec",
  name: "deploy " + hostname,

  steps : [
    {
      name: "fetch submodules",
      commands: [
        "git submodule update --init --recursive --remote"
      ]
    },
    Deploy(hostname, populate_unstable, populate_mailserver)
  ]
};

[
  //DeployPipeline("apu1", false, false),
  DeployPipeline("apu2", false, false),
  DeployPipeline("htz1", true, false),
  DeployPipeline("htz2", true, true),
  DeployPipeline("nas1", false, false),
  //DeployPipeline("nuc1", false, false),
  DeployPipeline("rpi2", false, false),
  DeployPipeline("ws1", true, false)
]

# Don't forget to run `make .drone.yml`
