local FetchSubmodules() = {
  name: "fetch submodules",
  commands: [
    "git submodule update --init --recursive --remote"
  ]
};

local WrapSSH(name, commands) = {
  name: name,
  commands: [
    "eval $(ssh-agent -s)",
    @"echo ""$SSH_KEY"" | tr -d '\r' | ssh-add -",
  ] + commands,
  environment: {
    SSH_KEY: {
      from_secret: "ssh-key"
    }
  }
};

local DeployPipeline(hostname, populate_unstable=false, populate_mailserver=false, prebuild_hass=false, hostdomain="host.nerdworks.de") = {
  kind: "pipeline",
  type: "exec",
  name: "deploy " + hostname,

  steps : [
    FetchSubmodules()    
  ] + (
    if prebuild_hass then [
      WrapSSH(
        "prebuild hass",
        ["nix-copy-closure --to root@" + hostname + "." + hostdomain + " $(nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/nwhass {}' -I /var/src)"]
      )
    ] else []
  ) + [
    WrapSSH(
      "deploy " + hostname,
      ["$(nix-build --no-out-link krops.nix --argstr name " + hostname + " --argstr starget root@" + hostname + "." + hostdomain + " --arg secrets false --arg unstable " + populate_unstable + " --arg mailserver " + populate_mailserver + " -A deploy -I /var/src)"]
    )
  ]
};

[
  //DeployPipeline("apu1"),
  DeployPipeline("apu2", prebuild_hass=true),
  DeployPipeline("htz1", populate_unstable=true),
  DeployPipeline("htz2", populate_unstable=true, populate_mailserver=true),
  DeployPipeline("htz3", hostdomain="host.fraam.de"),
  DeployPipeline("nas1", prebuild_hass=true),
  //DeployPipeline("nuc1"),
  DeployPipeline("rpi2"),
  DeployPipeline("ws1", populate_unstable=true)
]

# Don't forget to run `make .drone.yml`
