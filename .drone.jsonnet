local FetchSubmodules() = {
  name: 'fetch submodules',
  commands: [
    'git submodule update --init --recursive --remote',
  ],
};

local WrapSSH(name, commands) = {
  name: name,
  commands: [
    'eval $(ssh-agent -s)',
    @"echo ""$SSH_KEY"" | tr -d '\r' | ssh-add -",
  ] + commands,
  environment: {
    SSH_KEY: {
      from_secret: 'ssh-key',
    },
  },
};

local DeployPipeline(hostname, populate_unstable=false, populate_mailserver=false, prebuild=[], hostdomain='host.nerdworks.de', cmd='deploy') = {
  kind: 'pipeline',
  type: 'exec',
  name: cmd + ' ' + hostname,

  steps: [
           FetchSubmodules(),
         ] + [
           WrapSSH(
             'prebuild %s' % p,
             ['nix-copy-closure --to root@' + hostname + '.' + hostdomain + " $(nix-build -E 'with import <nixpkgs> {}; callPackage ./%s {}' -I /var/src)" % p]
           )
           for p in prebuild
         ]
         + [
           WrapSSH(
             'deploy ' + hostname,
             ['$(nix-build --no-out-link krops.nix --argstr name ' + hostname + ' --argstr starget root@' + hostname + '.' + hostdomain + ' --arg secrets false --arg unstable ' + populate_unstable + ' --arg mailserver ' + populate_mailserver + ' -A ' + cmd + ' -I /var/src)']
           ),
         ],
};

[
  //DeployPipeline("apu1"),
  //DeployPipeline('apu2', prebuild=['5pkgs/nwhass']),
  DeployPipeline('htz1', populate_unstable=true),
  DeployPipeline('htz2', populate_unstable=true, populate_mailserver=true, prebuild=['6cipkgs/bitwarden_rs']),
  DeployPipeline('htz3', hostdomain='host.fraam.de', prebuild=['5pkgs/traefik-forward-auth']),
  DeployPipeline('nas1', populate_unstable=true, prebuild=['5pkgs/nwhass']),
  //DeployPipeline("nuc1"),
  //DeployPipeline('rpi2'),
  DeployPipeline('ws1', populate_unstable=true, cmd='deploy_boot'),
]

// Don't forget to run `mk-drone-yml`



