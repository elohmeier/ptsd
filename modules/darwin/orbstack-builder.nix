{
  ...
}:

{
  environment.etc."ssh/ssh_config.d/100-linux-builder.conf".text = ''
    Host linux-builder
      User builder
      Hostname localhost
      HostKeyAlias linux-builder
      Port 31022
      IdentityFile /etc/nix/builder_ed25519
  '';

  nix.distributedBuilds = true;

  nix.buildMachines = [
    {
      hostName = "linux-builder";
      sshUser = "builder";
      sshKey = "/etc/nix/builder_ed25519";
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUxoT2tPWDVIcG13ZjdDWWlZMnNWQWZ5T1FTM3pNUTJWeXVPRWhPTXhQVGEgcm9vdEBuaXhvcy1idWlsZGVyCg==";
      maxJobs = 4;
      protocol = "ssh-ng";
      speedFactor = 1;
      supportedFeatures = [
        "kvm"
        "benchmark"
        "big-parallel"
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    }
  ];

  nix.settings = {
    builders-use-substitutes = true;
    trusted-users = [ "enno" ];
  };
}
