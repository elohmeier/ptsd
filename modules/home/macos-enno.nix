{ config, pkgs, ... }:

let
  docker-shell-completions = pkgs.runCommandNoCC "docker-shell-completions" { } ''
    mkdir -p $out/share
    cp -r ${pkgs.docker}/share/{bash-completion,fish,zsh} $out/share/
  '';
  secretiveSocket = "${config.home.homeDirectory}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
in
{
  home = {
    username = "enno";
    homeDirectory = "/Users/enno";
    sessionPath = [
      "${config.home.homeDirectory}/.cargo/bin" # cargo-managed
      "${config.home.homeDirectory}/.local/bin" # uv-managed
      "${config.home.homeDirectory}/.local/share/npm/bin"
      "${config.home.homeDirectory}/Applications/Ghostty.app/Contents/MacOS"
      "${config.home.homeDirectory}/go/bin"
      "${config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/bin"}"
      "/opt/homebrew/bin"
    ];
    sessionVariables = {
      # from https://github.com/wagoodman/dive/issues/542#issuecomment-2352251218
      DOCKER_HOST = "unix://${config.home.homeDirectory}/.orbstack/run/docker.sock";

      EDITOR = "nvim";

      SSH_AUTH_SOCK = secretiveSocket;
    };
    stateVersion = "21.11";
  };

  programs.fish.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      IdentityAgent ${secretiveSocket}
    '';
  };

  home.packages =
    [
      docker-shell-completions
    ]
    ++ (with pkgs; [
      act
      aerc
      aichat
      argo-workflows
      attic-client
      basedpyright
      binocle
      bombardier
      btop
      cmake
      colmena
      copier
      deno
      diceware
      dive
      dprint
      entr
      ffmpeg
      gh
      git-filter-repo
      go
      go-jsonnet
      google-cloud-sdk
      hcloud
      hexyl
      home-manager
      hyperfine
      jless
      jq
      jsonnet-bundler
      just
      k9s
      kubectl
      kubernetes-helm
      mkcert
      ncdu
      nix-melt
      nix-top
      nix-tree
      nix-update
      nixpacks
      nixvim-full-aw
      nodejs_latest
      numbat
      ollama
      opentofu
      packer
      pandoc
      pastel
      pnpm
      poppler_utils # pdfinfo
      pqrs
      pwgen
      qpdf
      rclone
      realise-symlink
      ripgrep
      ruff
      runpodctl
      rustup
      shellcheck
      shfmt
      skopeo
      sops
      sq
      ssh-to-age
      stress-ng
      stylua
      talosctl
      tanka
      typst
      typstyle
      uv
      vals
      watch
      wget
      xan
      xz
      yazi
      yq-go
      yt-dlp
    ]);

  home.file.".aider.conf.yml".source =
    let
      settings = {
        attribute-author = false;
        check-update = false;
        dirty-commits = false;
        lint-cmd = [ "python: ruff check" ];
        suggest-shell-commands = false;
      };
      yamlFormat = pkgs.formats.yaml { };
    in
    yamlFormat.generate "aider-config" settings;

  programs.gpg = {
    enable = true;
  };

  programs.nix-index-database.comma.enable = true;

  services.syncthing.enable = true;

  home.file.".hammerspoon".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/hammerspoon";

  programs.fish.shellAbbrs.hm = "home-manager --flake ${config.home.homeDirectory}/repos/ptsd/.#macos-enno --impure";

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
        "${homeDirectory}/*/.direnv/"
      ];
      prune = {
        keep = {
          within = "1d"; # Keep all archives from the last day
          daily = 7;
          weekly = 4;
          monthly = -1; # Keep at least one archive for each month
        };
      };
    in
    {
      hetzner = {
        inherit
          encryption
          environment
          exclude
          prune
          ;
        paths = [
          "${homeDirectory}/.config"
          "${homeDirectory}/Desktop"
          "${homeDirectory}/Documents"
          "${homeDirectory}/Maildir"
          "${homeDirectory}/Movies"
          "${homeDirectory}/Music"
          "${homeDirectory}/Pictures"
          "${homeDirectory}/Recordings"
          "${homeDirectory}/Sync"
          "${homeDirectory}/Templates"
        ];
        repo = "ssh://u267169-sub2@u267169.your-storagebox.de:23/./borg";
        compression = "zstd,3";
        postCreate = ''${pkgs.borg2prom}/bin/borg2prom --archive-name "$archiveName" --job-name hetzner --push'';
      };

      hetzner-documents = {
        inherit
          encryption
          environment
          exclude
          prune
          ;
        paths = [
          "${config.xdg.dataHome}/paperless"
          "${homeDirectory}/Documents"
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
        inherit encryption environment prune;
        paths = [
          "${homeDirectory}/.config"
          "${homeDirectory}/Desktop"
          "${homeDirectory}/Documents"
          "${homeDirectory}/Maildir"
          "${homeDirectory}/Movies"
          "${homeDirectory}/Music"
          "${homeDirectory}/Pictures"
          "${homeDirectory}/Recordings"
          "${homeDirectory}/Sync"
          "${homeDirectory}/Templates"
        ];
        repo = "ssh://borg-mb4@rpi4.pug-coho.ts.net/./";
        # repo = "ssh://borg-mb4@rpi4.fritz.box/./";
        compression = "zstd,3";
        postCreate = ''${pkgs.borg2prom}/bin/borg2prom --archive-name "$archiveName" --job-name rpi4 --push'';
      };
    };
}
