({ config, lib, pkgs, ... }: {
  home = {
    username = "enno";
    homeDirectory = "/Users/enno";
    sessionPath = [
      "${config.home.homeDirectory}/.docker/bin"
      "${config.home.homeDirectory}/.local/share/npm/bin"
      "${config.home.homeDirectory}/repos/flutter/bin"
      "${config.home.homeDirectory}/.pub-cache/bin"
      "/opt/homebrew/bin"
    ];
    stateVersion = "21.11";
  };

  # TODO: needed?
  # nixpkgs.config = {
  #   allowUnfreePredicate = _pkg: true; # https://github.com/nix-community/home-manager/issues/2942
  # };

  services.syncthing.enable = true;

  home.file.".hammerspoon".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/hammerspoon";

  programs.fish.shellAbbrs.hm = "home-manager --flake ${config.home.homeDirectory}/repos/ptsd/.#macos-enno --impure";

  home.sessionVariables.SSH_AUTH_SOCK = "${config.home.homeDirectory}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";

  launchd.agents.cleanup-downloads = {
    enable = true;
    config = {
      Program = toString (pkgs.writeShellScript "cleanup-downloads" ''
        ${pkgs.findutils}/bin/find "${config.home.homeDirectory}/Downloads" -ctime +5 -delete
      '');
      StartCalendarInterval = [{ Hour = 11; Minute = 0; }];
    };
  };

  ptsd.borgbackup.jobs = with config.home; let
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${homeDirectory}/.borgkey";
    };
    environment = {
      BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
      BORG_RSH = "ssh -i ${homeDirectory}/.ssh/nwbackup.id_ed25519";
    };
    exclude = [
      "${homeDirectory}/.Trash"
      "${homeDirectory}/.cache"
      "${homeDirectory}/.diffusionbee"
      "${homeDirectory}/.flair"
      "${homeDirectory}/.ollama/models"
      "${homeDirectory}/Applications"
      "${homeDirectory}/Downloads"
      "${homeDirectory}/Downloads-Keep"
      "${homeDirectory}/OrbStack"
      "${homeDirectory}/.orbstack"
      "${homeDirectory}/Library"
      "${homeDirectory}/Pictures/Photos Library.photoslibrary"
      "${homeDirectory}/Sync/rpi4-dl" # no backup
      "${homeDirectory}/repos/convexio/.minio"
      "${homeDirectory}/repos/convexio/.minio-prod"
      "${homeDirectory}/repos/llama.cpp/models"
      "${homeDirectory}/repos/stable-vicuna-13b-delta/*.bin"
      "${homeDirectory}/repos/whisper.cpp/models"
      "${homeDirectory}/roms" # no backup
      "*.pyc"
      "*.qcow2"
      "sh:${homeDirectory}/**/.cache"
      "sh:${homeDirectory}/**/node_modules"
      #"${homeDirectory}/Library/Caches"
      #"${homeDirectory}/Library/Trial"
      #"sh:${homeDirectory}/Library/Containers/*/Data/Library/Caches"
    ];
  in
  {
    hetzner = {
      inherit encryption environment exclude;
      paths = [ "${homeDirectory}" ];
      repo = "ssh://u267169-sub2@u267169.your-storagebox.de:23/./borg";
      compression = "zstd,3";
      postCreate = ''${pkgs.borg2prom}/bin/borg2prom --archive-name "$archiveName" --job-name hetzner --push'';
    };

    rpi4 = {
      inherit encryption environment;
      exclude = exclude ++ [
        "${homeDirectory}/Sync" # backed up via syncthing
      ];
      paths = [ "${homeDirectory}" ];
      #repo = "ssh://borg-mb4@rpi4.pug-coho.ts.net/./";
      repo = "ssh://borg-mb4@rpi4.fritz.box/./";
      compression = "zstd,3";
      postCreate = ''${pkgs.borg2prom}/bin/borg2prom --archive-name "$archiveName" --job-name rpi4 --push'';
    };
  };
})

