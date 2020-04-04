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

local DeployPipeline(hostname, populate_unstable) = {
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
    Deploy(hostname, populate_unstable)
  ]
};

[
  //DeployPipeline("apu1", false),
  DeployPipeline("htz1", true),
  DeployPipeline("htz2", true),
  DeployPipeline("nas1", false),
  //DeployPipeline("nuc1", false),
  DeployPipeline("ws1", true)
]

# Don't forget to run `make .drone.yml`
