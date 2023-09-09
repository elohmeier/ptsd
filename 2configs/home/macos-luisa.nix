({ config, pkgs, ... }: {
  home = {
    username = "luisa";
    homeDirectory = "/Users/luisa";
    stateVersion = "22.05";
  };

  home.packages = with pkgs;[ home-manager git nnn btop ];

  services.syncthing.enable = true;

  ptsd.borgbackup.jobs = with config.home; let
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${homeDirectory}/.borgkey";
    };
    environment.BORG_RSH = "ssh -i ${homeDirectory}/.ssh/nwbackup.id_ed25519";
    exclude = [
      "${homeDirectory}/.Trash"
      "${homeDirectory}/.cache"
      "${homeDirectory}/Applications"
      "${homeDirectory}/Downloads"
      "${homeDirectory}/Library"
      "${homeDirectory}/Pictures/Photos Library.photoslibrary"
      "sh:${homeDirectory}/**/.cache"
    ];
  in
  {
    hetzner = {
      inherit encryption environment exclude;
      paths = [ "${homeDirectory}" ];
      repo = "ssh://u267169-sub3@u267169.your-storagebox.de:23/./borg";
      compression = "zstd,3";
      postCreate = ''${pkgs.borg2prom}/bin/borg2prom --archive-name "$archiveName" --job-name hetzner --push'';
    };

    rpi4 = {
      inherit encryption environment exclude;
      paths = [ "${homeDirectory}" ];
      repo = "ssh://borg-mb3@rpi4.pug-coho.ts.net/./";
      compression = "zstd,3";
      postCreate = ''${pkgs.borg2prom}/bin/borg2prom --archive-name "$archiveName" --job-name rpi4 --push'';
    };
  };
})

