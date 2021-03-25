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

local DeployPipeline(hostname, populate_home_manager=false, prebuild=[], hostdomain='host.nerdworks.de', cmd='deploy') = {
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
             cmd + ' ' + hostname,
             ['$(nix-build --no-out-link krops.nix --argstr name ' + hostname + ' --argstr starget root@' + hostname + '.' + hostdomain + ' --arg secrets false --arg home-manager ' + populate_home_manager + ' -A ' + cmd + ' -I /var/src)']
           ),
         ],
};

[
  //DeployPipeline("apu1"),
  //DeployPipeline('apu2', prebuild=['5pkgs/nwhass']),
  //DeployPipeline('htz1', prebuild=['5pkgs/traefik']),
  //DeployPipeline('htz2', prebuild=['5pkgs/traefik']),
  //DeployPipeline('htz3', hostdomain='host.fraam.de', prebuild=['5pkgs/traefik-forward-auth', '5pkgs/traefik']),
  //DeployPipeline('nas1', populate_home_manager=true, prebuild=['5pkgs/nwhass', '5pkgs/traefik']),
  //DeployPipeline("nuc1"),
  //DeployPipeline('rpi2'),
  DeployPipeline('ws1', populate_home_manager=true, cmd='deploy_boot'),
]

// Don't forget to run `mk-drone-yml`



