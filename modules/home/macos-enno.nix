{ config, pkgs, ... }:

let
  docker-shell-completions = pkgs.runCommandNoCC "docker-shell-completions" { } ''
    mkdir -p $out/share
    cp -r ${pkgs.docker}/share/{bash-completion,fish,zsh} $out/share/
  '';
in
{
  home = {
    username = "enno";
    homeDirectory = "/Users/enno";
    sessionPath = [
      "${config.home.homeDirectory}/.local/bin" # uv-managed
      "${config.home.homeDirectory}/.local/share/cargo/bin"
      "${config.home.homeDirectory}/.local/share/npm/bin"
      "${config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/bin"}"
      "/opt/homebrew/bin"
    ];
    stateVersion = "21.11";
  };

  home.packages =
    [
      docker-shell-completions
    ]
    ++ (with pkgs; [
      ffmpeg
      gh
      google-cloud-sdk
      hcloud
      home-manager
      jless
      mkcert
      ncdu_1
      nix-tree
      nodejs_latest
      ollama
      pnpm
      ptsd-nnn
      realise-symlink
      ripgrep
      rustup
      shellcheck
      shfmt
      sops
      ssh-to-age
      watch
      yt-dlp
    ]);

  home.file.".aider.conf.yml".source =
    let
      settings = {
        check-update = false;
        dirty-commits = false;
        lint-cmd = "[python: ruff check]";
        suggest-shell-commands = false;
      };
      yamlFormat = pkgs.formats.yaml { };
    in
    yamlFormat.generate "aider-config" settings;

  programs.nix-index-database.comma.enable = true;

  services.syncthing.enable = true;

  home.file.".hammerspoon".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/hammerspoon";

  programs.fish.shellAbbrs.hm = "home-manager --flake ${config.home.homeDirectory}/repos/ptsd/.#macos-enno --impure";

  home.sessionVariables.SSH_AUTH_SOCK = "${config.home.homeDirectory}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";

  launchd.agents.cleanup-downloads = {
    enable = true;
    config = {
      Program = toString (
        pkgs.writeShellScript "cleanup-downloads" ''
          ${pkgs.findutils}/bin/find "${config.home.homeDirectory}/Downloads" -ctime +5 -delete
        ''
      );
      StartCalendarInterval = [
        {
          Hour = 11;
          Minute = 0;
        }
      ];
    };
  };

  ptsd.borgbackup.jobs =
    with config.home;
    let
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
        "${homeDirectory}/.orbstack"
        "${homeDirectory}/Applications"
        "${homeDirectory}/Downloads"
        "${homeDirectory}/Downloads-Keep"
        "${homeDirectory}/Library"
        "${homeDirectory}/OrbStack"
        "${homeDirectory}/Pictures/Photos Library.photoslibrary"
        "${homeDirectory}/Sync/rpi4-dl" # no backup
        "${homeDirectory}/repos/convexio/.minio"
        "${homeDirectory}/repos/convexio/.minio-prod"
        "${homeDirectory}/repos/flutter/bin/cache"
        "${homeDirectory}/repos/llama.cpp/models"
        "${homeDirectory}/repos/stable-vicuna-13b-delta"
        "${homeDirectory}/repos/stable-vicuna-13b-delta/*.bin"
        "${homeDirectory}/repos/tauri-app/src-tauri/target"
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

      hetzner-documents = {
        inherit encryption environment;
        paths = [
          "${config.xdg.dataHome}/paperless"
          "${homeDirectory}/Documents"
          "${homeDirectory}/Documents-Luisa"
          "${homeDirectory}/Sync/Scans-Enno"
          "${homeDirectory}/Sync/Scans-Laiyer"
          "${homeDirectory}/Sync/Scans-Luisa"
          "${homeDirectory}/Sync/iOS"
        ];
        repo = "ssh://u267169-sub2@u267169.your-storagebox.de:23/./borg-documents";
        compression = "zstd,3";
        postCreate = ''${pkgs.borg2prom}/bin/borg2prom --archive-name "$archiveName" --job-name hetzner-documents --push'';
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
}
