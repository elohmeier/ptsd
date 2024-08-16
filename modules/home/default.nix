{
  self,
  lib,
  withSystem,
  inputs,
  ...
}:

{
  flake.homeModules = {
    borgbackup = ./borgbackup.nix;
    darwin-defaults = ./darwin-defaults.nix;
    fish = ./fish.nix;
    fonts = ./fonts.nix;
    git = ./git.nix;
    gpg = ./gpg.nix;
    macos-enno = ./macos-enno.nix;
    neovim = ./neovim.nix;
    orb = ./orb.nix;
    packages = ./packages.nix;
    # paperless = ./paperless.nix;
    ssh = ./ssh.nix;
    tmux = ./tmux.nix;
    tp3 = ./tp3.nix;
    xdg-fixes = ./xdg-fixes.nix;
  };

  flake.homeConfigurations = {
    macos-enno = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "aarch64-darwin";
        overlays = [
          self.overlays.default
          inputs.nvim-config.overlays.default
        ];
        config.allowUnfree = true;
      };

      extraSpecialArgs = {
        pkgsUnstable = import inputs.nixpkgs-unstable {
          system = "aarch64-darwin";
          overlays = [
            self.overlays.default
            inputs.nvim-config.overlays.default
          ];
          config.allowUnfree = true;
        };
      };

      modules = [
        # self.homeModules.paperless
        inputs.nix-index-database.hmModules.nix-index
        self.homeModules.borgbackup
        self.homeModules.darwin-defaults
        self.homeModules.fish
        self.homeModules.fonts
        self.homeModules.git
        self.homeModules.gpg
        self.homeModules.macos-enno
        self.homeModules.neovim
        self.homeModules.packages
        self.homeModules.ssh
        self.homeModules.tmux
        self.homeModules.xdg-fixes
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

      extraSpecialArgs = {
        pkgsUnstable = import inputs.nixpkgs-unstable {
          system = "aarch64-linux";
          overlays = [
            inputs.nixcfg.overlays.default
            inputs.nvim-config.overlays.default
            self.overlays.default
          ];
          config.allowUnfree = true;
        };
      };

      modules = [
        self.homeModules.fish
        self.homeModules.git
        self.homeModules.neovim
        self.homeModules.ssh
        self.homeModules.tmux
        self.homeModules.orb
        {
          home = {
            username = "enno";
            homeDirectory = "/home/enno";
            stateVersion = "23.05";
          };
        }
      ];
    };

    xfce95 = inputs.home-manager.lib.homeManagerConfiguration {
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
        inputs.nix95.homeModules.nix95
        self.homeModules.fish
        self.homeModules.fonts
        self.homeModules.git
        self.homeModules.gpg
        self.homeModules.neovim
        self.homeModules.packages
        self.homeModules.ssh
        self.homeModules.tmux
        self.homeModules.tp3
        self.homeModules.xdg-fixes
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
        self.homeModules.neovim
        self.homeModules.packages
        self.homeModules.ssh
        self.homeModules.tmux
        self.homeModules.xdg-fixes
        { home.stateVersion = "23.05"; }
      ];
    };
  };

}
