{
  description = "ptsd";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;
    #nixpkgs-master.url = github:NixOS/nixpkgs/master;
    home-manager.url = github:nix-community/home-manager/release-22.05;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = github:NixOS/nixos-hardware/master;
    flake-utils.url = github:numtide/flake-utils;
    fraamdb.url = "git+ssh://git@github.com/elohmeier/fraamdb";
    fraamdb.inputs.nixpkgs.follows = "nixpkgs";
    neovim-flake.url = "github:neovim/neovim?dir=contrib";
    #neovim-flake.inputs.nixpkgs.follows = "nixpkgs-master";
    neovim-flake.inputs.nixpkgs.follows = "nixpkgs";
    neovim-flake.inputs.flake-utils.follows = "flake-utils";
  };

  outputs =
    { self
    , nixpkgs
      #, nixpkgs-master
    , home-manager
    , nixos-hardware
    , flake-utils
    , fraamdb
    , neovim-flake
    , ...
    }:

    let
      pkgOverrides = pkgs:
        #let pkgs_master = import nixpkgs-master { config.allowUnfree = true; system = pkgs.system; }; in
        super: (import ./5pkgs pkgs pkgs nixpkgs neovim-flake super);
    in
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs {
          config.allowUnfree = true; inherit system;
          config.packageOverrides = pkgOverrides pkgs;
        };

      in
      {
        packages = pkgs;
      })
    // {
      nixosConfigurations =
        let
          defaultModules = [
            ./3modules
            ({ pkgs, ... }:
              {
                nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
                nixpkgs.config = { allowUnfree = true; packageOverrides = pkgOverrides pkgs; };
              })
          ];
          #desktopModules = [
          #  ./2configs/users/enno.nix
          #  { nix.nixPath = [ "home-manager=${home-manager}" ]; }
          #  home-manager.nixosModule
          #  ({ pkgs, ... }:
          #    {
          #      home-manager.useGlobalPkgs = true;
          #      home-manager.users.mainUser = { nixosConfig, ... }:
          #        {
          #          imports = [
          #            ./3modules/home
          #          ];

          #          # workaround https://github.com/nix-community/home-manager/issues/2333
          #          disabledModules = [ "config/i18n.nix" ];
          #          home.sessionVariables.LOCALE_ARCHIVE_2_27 = "${nixosConfig.i18n.glibcLocales}/lib/locale/locale-archive";
          #          systemd.user.sessionVariables.LOCALE_ARCHIVE_2_27 = "${nixosConfig.i18n.glibcLocales}/lib/locale/locale-archive";
          #        };
          #    })
          #];
        in
        {

          apu2 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./1systems/apu2/physical.nix
              home-manager.nixosModule
            ];
          };

          htz1 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./1systems/htz1/physical.nix
              home-manager.nixosModule
            ];
          };

          htz2 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./1systems/htz2/physical.nix
              home-manager.nixosModule
            ];
          };

          htz3 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./1systems/htz3/physical.nix
              fraamdb.nixosModules.fraamdb
              home-manager.nixosModule
            ];
          };

          nas1 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./1systems/nas1/physical.nix
            ];
          };

          rpi2 = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              ./1systems/rpi2/physical.nix
            ];
          };

          ws1 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./1systems/ws1/physical.nix
            ];
            specialArgs = { inherit nixos-hardware home-manager pkgOverrides; };
          };

          pine2 = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              ./1systems/pine2/physical.nix
            ];
          };

          pine2_cross = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./1systems/pine2/physical.nix
              ({ lib, ... }: {
                nixpkgs.crossSystem = lib.systems.examples.aarch64-multiplatform;
              })
            ];
          };

          # run `nix build .#nixosConfigurations.pine2_sdimage.config.system.build.sdImage` to build image
          pine2_sdimage = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              ({ config, lib, modulesPath, pkgs, ... }: {
                imports = [
                  ./2configs/sd-image.nix
                  ./2configs/hw/pinephone-pro
                  (modulesPath + "/profiles/installation-device.nix")
                ];

                environment.systemPackages = with pkgs; [
                  foot.terminfo
                  file
                  gptfdisk
                  cryptsetup
                  f2fs-tools
                  xfsprogs.bin
                  gitMinimal
                ];

                nix.package = pkgs.nixFlakes;

                users.users.nixos.openssh.authorizedKeys.keys = (import ./2configs/users/ssh-pubkeys.nix).authorizedKeys_enno;
                users.users.root.openssh.authorizedKeys.keys = (import ./2configs/users/ssh-pubkeys.nix).authorizedKeys_enno;

                sdImage = {
                  populateFirmwareCommands = "";
                  populateRootCommands = ''
                    mkdir -p ./files/boot
                    ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
                  '';
                };

                networking = {
                  useNetworkd = true;
                  useDHCP = false;
                  wireless.enable = false;
                  wireless.iwd.enable = true;
                  networkmanager = {
                    enable = true;
                    dns = "systemd-resolved";
                    wifi.backend = "iwd";
                  };
                };
                services.resolved.enable = true;
                services.resolved.dnssec = "false";
              })
            ];
          };

          utmvm_x86 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./1systems/utmvm/physical.nix
            ];
          };

          utmvm = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              ./1systems/utmvm/physical.nix
            ];
          };

        };

      homeConfigurations = {

        sway_x86 = home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          username = "enno";
          homeDirectory = "/home/enno";
          stateVersion = "22.05";

          configuration = { config, lib, pkgs, ... }: {

            imports = [
              ./2configs/home/alacritty.nix
              ./2configs/home/firefox.nix
              ./2configs/home/fish.nix
              ./2configs/home/fonts.nix
              ./2configs/home/foot.nix
              ./2configs/home/git.nix
              ./2configs/home/i3status.nix
              ./2configs/home/gpg.nix
              ./2configs/home/logseq-sync-git.nix
              ./2configs/home/neovim.nix
              ./2configs/home/packages.nix
              ./2configs/home/ssh.nix
              ./2configs/home/sway.nix
              ./2configs/home/xdg.nix
              ./3modules/home
            ];

            nixpkgs.config = {
              allowUnfree = true;
              packageOverrides = pkgOverrides pkgs;
            };

            programs.direnv.enable = true;
            programs.direnv.nix-direnv.enable = true;

            # services.syncthing.enable = true;
          };
        };

        sway = home-manager.lib.homeManagerConfiguration {
          system = "aarch64-linux";
          username = "enno";
          homeDirectory = "/home/enno";
          stateVersion = "22.05";

          configuration = { config, lib, pkgs, ... }: {

            imports = [
              #./2configs/home/gpg.nix
              ./2configs/home/alacritty.nix
              ./2configs/home/firefox.nix
              ./2configs/home/fish.nix
              ./2configs/home/fonts.nix
              ./2configs/home/git.nix
              ./2configs/home/neovim.nix
              ./2configs/home/packages.nix
              ./2configs/home/ssh.nix
              ./2configs/home/sway.nix
              ./2configs/home/xdg.nix
              ./3modules/home
            ];

            nixpkgs.config = {
              allowUnfree = true;
              packageOverrides = pkgOverrides pkgs;
            };

            programs.direnv.enable = true;
            programs.direnv.nix-direnv.enable = true;

            services.syncthing.enable = true;
          };
        };

        macos-enno = home-manager.lib.homeManagerConfiguration {
          system = "aarch64-darwin";
          username = "enno";
          homeDirectory = "/Users/enno";
          stateVersion = "21.11";

          configuration = { config, lib, pkgs, ... }: {
            imports = [
              ./3modules/home
              ./2configs/home/alacritty.nix
              ./2configs/home/darwin-defaults.nix
              ./2configs/home/email.nix
              ./2configs/home/firefox.nix
              ./2configs/home/fish.nix
              ./2configs/home/fonts.nix
              ./2configs/home/git.nix
              ./2configs/home/gpg.nix
              ./2configs/home/neovim.nix
              ./2configs/home/packages.nix
              ./2configs/home/ssh.nix
            ];

            nixpkgs.config = {
              allowUnfree = true;
              packageOverrides = pkgOverrides pkgs;
            };

            services.syncthing.enable = true;

            programs.direnv.enable = true;
            programs.direnv.nix-direnv.enable = true;

            programs.zoxide.enable = true;

            home.file.".hammerspoon".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/hammerspoon";

            programs.fish = {
              enable = true;
              shellAliases = {
                gapf = "git commit --amend --no-edit && git push --force";
                gaapf = "git add . && git commit --amend --no-edit && git push --force";
                grep = "grep --color";
                ping6 = "ping -6";
                telnet = "screen //telnet";
                vim = "nvim";
                vi = "nvim";
                l = "exa -al";
                la = "exa -al";
                lg = "exa -al --git";
                ll = "exa -l";
                ls = "exa";
                tree = "exa --tree";
              };

              shellAbbrs = {
                "cd.." = "cd ..";

                # git
                ga = "git add";
                "ga." = "git add .";
                gc = "git commit";
                gco = "git checkout";
                gd = "git diff";
                gf = "git fetch";
                gl = "git log";
                gs = "git status";
                gp = "git pull";
                gpp = "git push";

                hm = "home-manager --flake ${config.home.homeDirectory}/repos/ptsd/.#macos-enno --override-input home-manager ${config.home.homeDirectory}/repos/home-manager";
              };
            };
          };
        };
      };
    };
}
