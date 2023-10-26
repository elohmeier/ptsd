{ self, lib, withSystem, inputs, ... }:

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
    packages = ./packages.nix;
    paperless = ./paperless.nix;
    ssh = ./ssh.nix;
    tmux = ./tmux.nix;
    xdg-fixes = ./xdg-fixes.nix;
  };

  flake.homeConfigurations = {
    macos-enno = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs-unstable {
        system = "aarch64-darwin";
        overlays = [ self.overlays.default ];
        config.allowUnfree = true;
      };

      modules = [
        # ./modules/home
        # ./modules/home/darwin-defaults.nix
        # ./modules/home/fish.nix
        # ./modules/home/fonts.nix
        # ./modules/home/git.nix
        # ./modules/home/gpg.nix
        # ./modules/home/macos-enno.nix
        # ./modules/home/neovim.nix
        # ./modules/home/packages.nix
        # ./modules/home/paperless.nix
        # ./modules/home/ssh.nix
        # ./modules/home/tmux.nix
        # ./modules/home/xdg-fixes.nix
        self.homeModules.borgbackup
        self.homeModules.darwin-defaults
        self.homeModules.fish
        self.homeModules.fonts
        self.homeModules.git
        self.homeModules.gpg
        self.homeModules.macos-enno
        self.homeModules.neovim
        self.homeModules.packages
        self.homeModules.paperless
        self.homeModules.ssh
        self.homeModules.tmux
        self.homeModules.xdg-fixes
      ];
    };

    xfce95 = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        overlays = [ self.overlays.default ];
        config.allowUnfree = true;
      };

      modules = [
        ./fish.nix
        ./fonts.nix
        ./git.nix
        ./gpg.nix
        ./neovim.nix
        ./packages.nix
        ./ssh.nix
        ./tmux.nix
        ./xdg-fixes.nix
        ./tp3.nix
        { home.stateVersion = "23.05"; }
      ];
    };
  };

}
