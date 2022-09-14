{
  description = "ptsd";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;
    #nixpkgs-unstable.url = github:NixOS/nixpkgs/nixos-unstable;
    #nixpkgs-master.url = github:NixOS/nixpkgs/master;
    #home-manager.url = github:nix-community/home-manager/release-22.05;
    home-manager.url = github:elohmeier/home-manager/darwin-wip;
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
      #, nixpkgs-unstable
    , home-manager
    , nixos-hardware
    , flake-utils
    , fraamdb
    , neovim-flake
    , ...
    }:

    let
      pkgOverrides = pkgs:
        #let pkgs_master = import nixpkgs-unstable { config.allowUnfree = true; system = pkgs.system; }; in
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

          rpi3 = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              ./1systems/rpi3
            ];
          };

          rpi4 = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              nixos-hardware.nixosModules.raspberry-pi-4
              ./1systems/rpi4
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

          mb4-nixos = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              #./2configs/rpi-netboot.nix
              ./2configs/utm-i3.nix
              ./2configs/utmvm.nix
              ./2configs/vm-efi-xfs.nix
              {
                time.timeZone = "Europe/Berlin";
                networking.hostName = "mb4-nixos";
                system.stateVersion = "22.05";
                virtualisation.docker = { enable = true; enableOnBoot = false; };
              }
            ];
            specialArgs = { inherit nixpkgs; };
          };

          hyperv_x86 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./2configs/hypervvm.nix
              ./2configs/vm-efi-xfs.nix
              {
                fileSystems."/".device = "/dev/sda2";
                fileSystems."/boot".device = "/dev/sda1";
              }
            ];
          };

          vbox_x86 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./2configs/vbox.nix
              ./2configs/utm-i3.nix
            ];
          };

          ws2-nixos = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./2configs/klipper.nix
              ./2configs/vbox.nix
              ./2configs/utm-i3.nix
              {
                documentation = {
                  enable = false;
                  man.enable = false;
                  info.enable = false;
                  doc.enable = false;
                  dev.enable = false;
                };
                networking.hostName = "ws2-nixos";
                system.stateVersion = "22.05";
              }
            ];
          };

          utmvm_x86 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./2configs/utmvm.nix
              ./2configs/vm-efi-xfs.nix
            ];
          };

          utmvm_i3_x86 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = defaultModules ++ [
              ./2configs/utmvm.nix
              ./2configs/utm-i3.nix
              ./2configs/vm-efi-xfs.nix
              {
                system.stateVersion = "22.05";
                virtualisation.docker = { enable = true; enableOnBoot = false; };
              }
            ];
          };

          utmvm = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              ./2configs/utmvm.nix
              ./2configs/vm-efi-xfs.nix
            ];
          };

          utmvm_qcow = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              ./2configs/utmvm.nix
              ./2configs/utm-i3.nix
              ./2configs/qcow-efi.nix
              home-manager.nixosModule
              ({ config, lib, modulesPath, pkgs, ... }: {
                system.stateVersion = "22.05";
                virtualisation.docker = { enable = true; enableOnBoot = false; };

                home-manager.useGlobalPkgs = true;
                home-manager.users.mainUser = { config, lib, pkgs, nixosConfig, ... }:
                  {
                    home.stateVersion = "22.05";
                    imports = [
                      ./2configs/home
                      ./2configs/home/alacritty.nix
                      ./2configs/home/firefox.nix
                      ./2configs/home/fish.nix
                      ./2configs/home/fonts.nix
                      ./2configs/home/git.nix
                      ./2configs/home/gpg.nix
                      ./2configs/home/i3.nix
                      ./2configs/home/i3status.nix
                      ./2configs/home/neovim.nix
                      ./2configs/home/packages.nix
                      ./2configs/home/ssh.nix
                      ./2configs/home/xdg.nix
                    ];
                    nixpkgs.config = {
                      allowUnfree = true;
                      packageOverrides = pkgOverrides pkgs;
                    };
                    services.syncthing.enable = true;
                  };
              })
            ];
          };
        };

      homeConfigurations =
        let
          desktopImports = [
            ./2configs/home
            ./2configs/home/firefox.nix
            ./2configs/home/fish.nix
            ./2configs/home/fonts.nix
            ./2configs/home/git.nix
            ./2configs/home/gpg.nix
            ./2configs/home/neovim.nix
            ./2configs/home/packages.nix
            ./2configs/home/ssh.nix
          ];
        in
        {

          sway_x86 = home-manager.lib.homeManagerConfiguration {
            system = "x86_64-linux";
            username = "enno";
            homeDirectory = "/home/enno";
            stateVersion = "22.05";

            configuration = { config, lib, pkgs, ... }: {

              imports = desktopImports ++ [
                ./2configs/home/foot.nix
                ./2configs/home/i3status.nix
                ./2configs/home/sway.nix
                ./2configs/home/xdg.nix
              ];

              nixpkgs.config = {
                allowUnfree = true;
                packageOverrides = pkgOverrides pkgs;
              };

              # services.syncthing.enable = true;
            };
          };

          sway_pine2 = home-manager.lib.homeManagerConfiguration {
            system = "aarch64-linux";
            username = "enno";
            homeDirectory = "/home/enno";
            stateVersion = "21.11";

            configuration = { config, lib, pkgs, ... }: {

              imports = desktopImports ++ [
                ./2configs/home/foot.nix
                ./2configs/home/i3status.nix
                ./2configs/home/sway.nix
                ./2configs/home/xdg.nix
              ];

              nixpkgs.config = {
                allowUnfree = true;
                packageOverrides = pkgOverrides pkgs;
              };
            };
          };

          i3_aarch64 = home-manager.lib.homeManagerConfiguration {
            system = "aarch64-linux";
            username = "enno";
            homeDirectory = "/home/enno";
            stateVersion = "22.05";

            configuration = { config, lib, pkgs, ... }: {

              imports = desktopImports ++ [
                ./2configs/home/alacritty.nix
                ./2configs/home/chromium.nix
                ./2configs/home/i3.nix
                ./2configs/home/i3status.nix
                ./2configs/home/xdg.nix
              ];

              nixpkgs.config = {
                allowUnfree = true;
                packageOverrides = pkgOverrides pkgs;
              };

              services.syncthing.enable = true;
            };
          };

          i3_x86 = home-manager.lib.homeManagerConfiguration {
            system = "x86_64-linux";
            username = "enno";
            homeDirectory = "/home/enno";
            stateVersion = "22.05";

            configuration = { config, lib, pkgs, ... }: {

              imports = desktopImports ++ [
                ./2configs/home/alacritty.nix
                ./2configs/home/chromium.nix
                ./2configs/home/i3.nix
                ./2configs/home/i3status.nix
                ./2configs/home/xdg.nix
              ];

              nixpkgs.config = {
                allowUnfree = true;
                packageOverrides = pkgOverrides pkgs;
              };

              services.syncthing.enable = true;
            };
          };

          macos-enno = home-manager.lib.homeManagerConfiguration {
            system = "aarch64-darwin";
            username = "enno";
            homeDirectory = "/Users/enno";
            stateVersion = "21.11";

            configuration = { config, lib, pkgs, ... }: {
              imports = desktopImports ++ [
                ./2configs/home/alacritty.nix
                ./2configs/home/darwin-defaults.nix
                ./2configs/home/email.nix
              ];

              nixpkgs.config = {
                allowUnfree = true;
                packageOverrides = pkgOverrides pkgs;
              };

              services.syncthing.enable = true;

              home.file.".hammerspoon".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/hammerspoon";
              programs.fish.shellAbbrs.hm = "home-manager --flake ${config.home.homeDirectory}/repos/ptsd/.#macos-enno --impure";

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
                  "${homeDirectory}/.cache"
                  "${homeDirectory}/Applications"
                  "${homeDirectory}/Downloads"
                  "${homeDirectory}/Downloads-Keep"
                  "${homeDirectory}/Library"
                  "${homeDirectory}/Pictures/Photos Library.photoslibrary"
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
                  postCreate = "${pkgs.borg2prom}/bin/borg2prom $archiveName hetzner";
                };

                rpi4 = {
                  inherit encryption environment;
                  exclude = exclude ++ [
                    "${homeDirectory}/Sync" # backed up via syncthing
                  ];
                  paths = [ "${homeDirectory}" ];
                  #repo = "ssh://borg-mb4@rpi4.pug-coho.ts.net/./";
                  repo = "ssh://borg-mb4@192.168.178.84/./";
                  compression = "zstd,3";
                  postCreate = "${pkgs.borg2prom}/bin/borg2prom $archiveName rpi4";
                };
              };
            };
          };

          macos-luisa = home-manager.lib.homeManagerConfiguration {
            system = "aarch64-darwin";
            username = "luisa";
            homeDirectory = "/Users/luisa";
            stateVersion = "22.05";

            configuration = { config, lib, pkgs, ... }: {
              imports = [
                ./2configs/home
              ];

              nixpkgs.config = {
                allowUnfree = true;
                packageOverrides = pkgOverrides pkgs;
              };

              home.packages = with pkgs;[ home-manager git ];

              services.syncthing.enable = true;

              ptsd.borgbackup.jobs = with config.home; let
                encryption = {
                  mode = "repokey-blake2";
                  passCommand = "cat ${homeDirectory}/.borgkey";
                };
                environment.BORG_RSH = "ssh -i ${homeDirectory}/.ssh/nwbackup.id_ed25519";
                exclude = [
                  "${homeDirectory}/.cache"
                  "${homeDirectory}/Applications"
                  "${homeDirectory}/Downloads"
                  "${homeDirectory}/Library/Caches"
                  "${homeDirectory}/Library/Trial"
                  "sh:${homeDirectory}/**/.cache"
                  "sh:${homeDirectory}/Library/Containers/*/Data/Library/Caches"
                ];
              in
              {
                hetzner = {
                  inherit encryption environment exclude;
                  paths = [ "${homeDirectory}" ];
                  repo = "ssh://u267169-sub3@u267169.your-storagebox.de:23/./borg";
                  compression = "zstd,3";
                  postCreate = "${pkgs.borg2prom}/bin/borg2prom $archiveName hetzner";
                };

                rpi4 = {
                  inherit encryption environment exclude;
                  paths = [ "${homeDirectory}" ];
                  repo = "ssh://borg-mb3@rpi4.pug-coho.ts.net/./";
                  compression = "zstd,3";
                  postCreate = "${pkgs.borg2prom}/bin/borg2prom $archiveName rpi4";
                };
              };
            };
          };
        };
    };
}
