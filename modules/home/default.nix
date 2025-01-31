{ self, inputs, ... }:

{
  flake.homeModules = {
    # paperless = ./paperless.nix;
    borgbackup = ./borgbackup.nix;
    darwin-defaults = ./darwin-defaults.nix;
    fish = ./fish.nix;
    fonts = ./fonts.nix;
    git = ./git.nix;
    gpg = ./gpg.nix;
    macos-enno = ./macos-enno.nix;
    orb = ./orb.nix;
    pass = ./pass.nix;
    packages = ./packages.nix;
    ssh = ./ssh.nix;
    tp3 = ./tp3.nix;
    xdg-fixes = ./xdg-fixes.nix;
  };

  flake.homeConfigurations = {
    macos-enno = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "aarch64-darwin";
        overlays = [
          inputs.nixcfg.overlays.default
          inputs.nvim-config.overlays.default
          self.overlays.default
        ];
        config.allowUnfree = true;
      };

      modules = [
        #self.homeModules.gpg
        #self.homeModules.packages
        #self.homeModules.paperless
        #self.homeModules.xdg-fixes
        ./process-compose.nix
        inputs.nix-index-database.hmModules.nix-index
        inputs.nixcfg.hmModules.cli-bat
        inputs.nixcfg.hmModules.cli-direnv
        inputs.nixcfg.hmModules.cli-fish
        inputs.nixcfg.hmModules.cli-git
        inputs.nixcfg.hmModules.cli-lazygit
        inputs.nixcfg.hmModules.cli-nnn
        inputs.nixcfg.hmModules.cli-tmux
        self.homeModules.borgbackup
        self.homeModules.darwin-defaults
        self.homeModules.fish
        self.homeModules.fonts
        self.homeModules.git
        self.homeModules.macos-enno
        self.homeModules.pass
        self.homeModules.ssh
      ];
    };

    orb = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "aarch64-linux";
        overlays = [
          inputs.nixcfg.overlays.default
          inputs.nvim-config.overlays.default
          self.overlays.default
        ];
        config.allowUnfree = true;
      };

      modules = [
        inputs.nixcfg.hmModules.cli-bat
        inputs.nixcfg.hmModules.cli-direnv
        inputs.nixcfg.hmModules.cli-fish
        inputs.nixcfg.hmModules.cli-git
        inputs.nixcfg.hmModules.cli-lazygit
        inputs.nixcfg.hmModules.cli-tmux
        self.homeModules.fish
        self.homeModules.git
        self.homeModules.orb
        self.homeModules.ssh
        {
          home = {
            username = "enno";
            homeDirectory = "/home/enno";
            stateVersion = "23.05";
          };
        }
      ];
    };

    tp3 = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        overlays = [
          self.overlays.default
          inputs.nvim-config.overlays.default
        ];
        config.allowUnfree = true;
      };

      extraSpecialArgs = {
        pkgsUnstable = import inputs.nixpkgs-unstable {
          system = "x86_64-linux";
          overlays = [
            self.overlays.default
            inputs.nvim-config.overlays.default
          ];
          config.allowUnfree = true;
        };
      };

      modules = [
        ./ssh-tpm-agent.nix
        inputs.nix-index-database.hmModules.nix-index
        inputs.nix95.homeModules.nix95
        inputs.nixcfg.hmModules.cli-bat
        inputs.nixcfg.hmModules.cli-direnv
        inputs.nixcfg.hmModules.cli-fish
        inputs.nixcfg.hmModules.cli-git
        inputs.nixcfg.hmModules.cli-lazygit
        inputs.nixcfg.hmModules.cli-tmux-ascii
        inputs.sops-nix.homeManagerModules.sops
        self.homeModules.fish
        self.homeModules.fonts
        self.homeModules.git
        self.homeModules.gpg
        self.homeModules.pass
        self.homeModules.ssh
        self.homeModules.tp3
        { home.stateVersion = "23.05"; }
      ];
    };

    xfce95_aarch64 = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "aarch64-linux";
        overlays = [ self.overlays.default ];
        config.allowUnfree = true;
      };

      modules = [
        inputs.nix95.homeModules.nix95
        self.homeModules.fish
        self.homeModules.fonts
        self.homeModules.git
        self.homeModules.gpg
        self.homeModules.lazygit
        self.homeModules.packages
        self.homeModules.ssh
        self.homeModules.tmux
        self.homeModules.xdg-fixes
        { home.stateVersion = "23.05"; }
      ];
    };
  };

}
