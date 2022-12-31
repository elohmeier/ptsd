{
  description = "ptsd";

  inputs = {
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:elohmeier/home-manager/release-22.11-darwin";
    nixinate.inputs.nixpkgs.follows = "nixpkgs";
    nixinate.url = "github:elohmeier/nixinate";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:elohmeier/nixpkgs/nixos-22.11-tpmfix";
  };

  outputs =
    { self
    , disko
    , flake-utils
    , home-manager
    , nixinate
    , nixos-hardware
    , nixpkgs
    , nixpkgs-unstable
    , ...
    }:

    let
      pkgOverrides = pkgs:
        let pkgs_master = import nixpkgs-unstable { config.allowUnfree = true; system = pkgs.system; }; in
        super: (import ./5pkgs pkgs pkgs_master nixpkgs super);
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
        packages = pkgs // {
          disko-init =
            let
              dcfg = import ./2configs/disko/lvm-immutable.nix { disk = "/dev/nvme0n1"; };
            in
            pkgs.writeShellScriptBin "disko-init" ''
              export PATH=${pkgs.lib.makeBinPath (disko.lib.packages dcfg pkgs)}
                echo "create partitions..."
              ${disko.lib.create dcfg}
              echo "mount partitions..."
              ${disko.lib.mount dcfg}
            '';
        };
      })
    // {
      apps = nixinate.nixinate.aarch64-darwin self;

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
          macvm = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              home-manager.nixosModule
              ({ config, lib, pkgs, modulesPath, ... }: {
                imports = [
                  "${modulesPath}/virtualisation/qemu-vm.nix"
                  ./2configs/users/enno.nix
                  ./2configs/devenv.nix
                ];
                users = {
                  users.mainUser = { group = "staff"; home = "/Users/enno"; uid = 502; };
                  groups = { lp.gid = lib.mkForce 420; staff.gid = 20; };
                };
                networking.nameservers = [ "8.8.8.8" ];
                system.stateVersion = "22.11";
                #programs.bash.loginShellInit = ''
                #  if [ -z "$TMUX" ]; then
                #    ${pkgs.tmux}/bin/tmux -CC
                #  fi
                #'';

                environment.systemPackages = with pkgs;[ qemu ];

                networking = {
                  firewall.trustedInterfaces = [ "eth0" ];
                };

                systemd.network.networks."40-eth" = {
                  matchConfig.Driver = "virtio_net";
                  networkConfig = {
                    DHCP = "yes";
                    IPv6PrivacyExtensions = "kernel";
                  };
                };

                home-manager.useGlobalPkgs = true;
                home-manager.users.mainUser = { config, lib, pkgs, nixosConfig, ... }:
                  {
                    home.stateVersion = "22.11";
                    imports = [
                      #./2configs/home/gpg.nix
                      ./2configs/home
                      ./2configs/home/fish.nix
                      ./2configs/home/git.nix
                      ./2configs/home/neovim.nix
                      #./2configs/home/packages.nix
                      ./2configs/home/ssh.nix
                      ./3modules/home
                    ];

                    # workaround https://github.com/nix-community/home-manager/issues/2333
                    disabledModules = [ "config/i18n.nix" ];
                    home.sessionVariables.LOCALE_ARCHIVE_2_27 = "${nixosConfig.i18n.glibcLocales}/lib/locale/locale-archive";
                    systemd.user.sessionVariables.LOCALE_ARCHIVE_2_27 = "${nixosConfig.i18n.glibcLocales}/lib/locale/locale-archive";

                    home.file.".local/share/fish/fish_history".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/fish/history/fish_history";

                    programs.fish.interactiveShellInit = ''
                      if test -z "$TMUX"
                        exec ${pkgs.tmux}/bin/tmux -CC
                      end
                    '';

                  };

                # fix root folder ownership from fish-history mount
                systemd.services.home-manager-enno = {
                  preStart = ''
                    chown -R enno:users /Users/enno/.local
                  '';
                  serviceConfig.PermissionsStartOnly = true;
                };

                virtualisation = {
                  additionalPaths = [ config.home-manager.users.mainUser.home.activationPackage ];

                  # vmnet-shared requires signed binaries, see https://github.com/utmapp/UTM/blob/main/Documentation/MacDevelopment.md#signed-packages
                  # qemu.networkingOptions = lib.mkForce [
                  #   "-net nic,netdev=net0,model=virtio"
                  #   "-netdev vmnet-shared,id=net0,\${QEMU_NET_OPTS:+,$QEMU_NET_OPTS}"
                  # ];
                  memorySize = 4096;
                  diskSize = 10000;
                  cores = 4;
                  forwardPorts = [
                    { from = "host"; host.port = 5001; guest.port = 5001; }
                  ];
                  graphics = false;
                  host.pkgs = nixpkgs.legacyPackages.aarch64-darwin; # qemu 7.1 required for 9p mount, not in 22.05
                  # host.pkgs = {
                  #   inherit (nixpkgs.legacyPackages.aarch64-darwin) runCommand writeScript runtimeShell coreutils;
                  #   qemu_kvm = nixpkgs.legacyPackages.aarch64-darwin.writeShellScriptBin "qemu-system-aarch64" ''
                  #     echo huhu
                  #   '';
                  # };
                  sharedDirectories = {
                    repos = { source = "/Users/enno/repos"; target = "/Users/enno/repos"; };
                    downloads = { source = "/Users/enno/Downloads"; target = "/Users/enno/Downloads"; };
                    downloads-keep = { source = "/Users/enno/Downloads-Keep"; target = "/Users/enno/Downloads-Keep"; };
                    fish-history = { source = "/Users/enno/.local/share/fish/history"; target = "/Users/enno/.local/share/fish/history"; };
                    zoxide-data = { source = "/Users/enno/Library/Application\\ Support/zoxide"; target = "/Users/enno/.local/share/zoxide"; };
                  };
                };
              })
            ];
          };

          iso = nixpkgs.lib.nixosSystem
            {
              system = "x86_64-linux";
              modules = defaultModules ++ [
                ({ config, lib, modulesPath, pkgs, ... }: {
                  imports = [
                    (modulesPath + "/profiles/installation-device.nix")
                    (modulesPath + "/installer/cd-dvd/iso-image.nix")
                  ];
                  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_0.override {
                    argsOverride = rec {
                      src = pkgs.fetchFromGitHub {
                        owner = "torvalds";
                        repo = "linux";
                        rev = "v${version}";
                        sha256 = "sha256-FbXvv2fV/2JA81DRtglQXf0pL1SON5o3bx2hrHv/Dug=";
                      };
                      version = "6.1-rc6";
                      modDirVersion = "6.1.0-rc6";
                    };
                  });
                  isoImage.makeEfiBootable = true;
                  isoImage.makeUsbBootable = true;
                  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}-linux${config.boot.kernelPackages.kernel.modDirVersion}.iso";
                  users.users.nixos.openssh.authorizedKeys.keys = (import ./2configs/users/ssh-pubkeys.nix).authorizedKeys_enno;
                  users.users.root.openssh.authorizedKeys.keys = (import ./2configs/users/ssh-pubkeys.nix).authorizedKeys_enno;

                  environment.systemPackages =
                    with pkgs;
                    let
                      dcfg = import ./2configs/disko/lvm-immutable.nix { disk = "/dev/nvme0n1"; };
                    in
                    [

                      (pkgs.writeShellScriptBin "disko-create-lvm-immutable-nvme0n1" ''
                        export PATH=${lib.makeBinPath (disko.lib.packages dcfg pkgs)}
                        ${disko.lib.create dcfg}
                      '')
                      (pkgs.writeShellScriptBin "disko-mount-lvm-immutable-nvme0n1" ''
                        export PATH=${lib.makeBinPath (disko.lib.packages dcfg pkgs)}
                        ${disko.lib.mount dcfg}
                      '')

                      btop
                      gitMinimal
                      neovim
                      nnn
                      tmux
                    ];

                  boot.supportedFilesystems = [ "ntfs" ];

                  console.keyMap = "de-latin1";
                  services.xserver.layout = "de";
                  i18n.defaultLocale = "de_DE.UTF-8";
                  time.timeZone = "Europe/Berlin";
                  #hardware.enableAllFirmware = true;
                  networking = {
                    useNetworkd = true;
                    useDHCP = false;
                    wireless.enable = false;
                    wireless.iwd.enable = true;
                    interfaces.eth0.useDHCP = true;
                    interfaces.wlan0.useDHCP = true;
                    networkmanager.wifi.backend = "iwd";
                    usePredictableInterfaceNames = false;
                  };

                  system.activationScripts.configure-iwd = nixpkgs.lib.stringAfter [ "users" "groups" ] ''
                    mkdir -p /var/lib/iwd
                    cat >/var/lib/iwd/Bundesdatenschutzzentrale.psk <<EOF
                    [Security]
                    Passphrase=
                    EOF
                  '';

                  nix = {
                    package = pkgs.nixFlakes;
                    extraOptions = "experimental-features = nix-command flakes";
                  };

                })
              ];
            };

          tp3 = nixpkgs.lib.nixosSystem
            {
              system = "x86_64-linux";
              modules = defaultModules ++ [
                home-manager.nixosModule
                ({ config, lib, pkgs, modulesPath, ... }: {
                  imports = [
                    ./2configs
                    ./2configs/devenv.nix
                    ./2configs/nix-persistent.nix
                  ];
                  #boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_0.override {
                  #  argsOverride = rec {
                  #    src = pkgs.fetchFromGitHub {
                  #      owner = "torvalds";
                  #      repo = "linux";
                  #      rev = "v${version}";
                  #      sha256 = "sha256-FbXvv2fV/2JA81DRtglQXf0pL1SON5o3bx2hrHv/Dug=";
                  #    };
                  #    version = "6.1-rc6";
                  #    modDirVersion = "6.1.0-rc6";
                  #  };
                  #});
                  boot.kernelPackages = pkgs.linuxPackages_latest;
                  system.stateVersion = "22.11";

                  environment.systemPackages = with pkgs; [
                    btop
                    gitMinimal
                    neovim
                    nnn
                    tmux
                  ];

                  #users.users.mainUser.home = "/win/Users/gordon";

                  console.keyMap = "de-latin1";
                  services.xserver.layout = "de";
                  i18n.defaultLocale = "de_DE.UTF-8";
                  time.timeZone = "Europe/Berlin";
                  hardware.enableAllFirmware = true;
                  networking = {
                    hostName = "tp3";
                    useDHCP = false;
                    useNetworkd = true;
                    wireless.iwd.enable = true;
                  };
                  systemd.network.networks = {
                    eth = {
                      dhcpV4Config.RouteMetric = 10;
                      ipv6AcceptRAConfig.RouteMetric = 10;
                      linkConfig.RequiredForOnline = "no";
                      matchConfig.Type = "ether";
                      networkConfig = { ConfigureWithoutCarrier = true; DHCP = "yes"; };
                    };
                    wlan = {
                      dhcpV4Config.RouteMetric = 20;
                      ipv6AcceptRAConfig.RouteMetric = 20;
                      matchConfig.Type = "wlan";
                      networkConfig.DHCP = "yes";
                    };
                  };
                  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" "ntfs3" "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sr_mod" ];
                  boot.initrd.kernelModules = [ "amdgpu" ];
                  boot.kernelModules = [ "kvm-amd" ];

                  boot.loader.systemd-boot.enable = true;
                  boot.loader.systemd-boot.configurationLimit = 1;
                  boot.loader.efi.canTouchEfiVariables = true;

                  fileSystems."/" =
                    {
                      fsType = "tmpfs";
                      options = [ "size=2G" "mode=1755" ];
                    };
                  #fileSystems."/win" =
                  #  {
                  #    device = "/dev/disk/by-uuid/320EF3900EF34AFD";
                  #    fsType = "ntfs3";
                  #    options = [ "discard" "acl" "nofail" "uid=1000" "gid=100" ];
                  #    noCheck = true;
                  #  };

                  fileSystems."/nix" =
                    {
                      device = "/dev/disk/by-uuid/4c5e4adb-cffa-4143-95b9-6b15fa08eb23";
                      fsType = "ext4";
                    };

                  fileSystems."/boot" =
                    {
                      #device = "/dev/disk/by-uuid/BEF2-2750";
                      device = "/dev/disk/by-uuid/055E-8702";
                      fsType = "vfat";
                    };

                  hardware = {
                    cpu.amd.updateMicrocode = true;
                    firmware = with pkgs; [
                      firmwareLinuxNonfree
                    ];
                  };

                  boot.tmpOnTmpfs = true;
                  boot.initrd.systemd = {
                    enable = true;
                    emergencyAccess = true;
                  };
                  ptsd.secrets.enable = false;

                  services.xserver = {
                    enable = true;
                    desktopManager = {
                      xterm.enable = false;
                      xfce.enable = true;
                    };
                    displayManager = {
                      defaultSession = "xfce";
                      autoLogin = {
                        enable = true;
                        user = "enno";
                      };
                    };
                  };

                  #boot.consoleLogLevel = 7;
                  #services.journald.console = "/dev/console";

                  virtualisation.virtualbox.guest.enable = true;
                })
              ];
            };

          apu2 = nixpkgs.lib.nixosSystem
            {
              system = "x86_64-linux";
              modules = defaultModules ++ [
                ./1systems/apu2/physical.nix
                home-manager.nixosModule
              ];
            };

          htz1 = nixpkgs.lib.nixosSystem
            {
              system = "x86_64-linux";
              modules = defaultModules ++ [
                ./1systems/htz1/physical.nix
                { _module.args.nixinate = { host = "htz1.nn42.de"; sshUser = "root"; buildOn = "remote"; }; }
              ];
            };

          htz2 = nixpkgs.lib.nixosSystem
            {
              system = "x86_64-linux";
              modules = defaultModules ++ [
                ./1systems/htz2/physical.nix
                { _module.args.nixinate = { host = "htz2.nn42.de"; sshUser = "root"; buildOn = "remote"; }; }
              ];
            };

          # nas1 = nixpkgs.lib.nixosSystem {
          #   system = "x86_64-linux";
          #   modules = defaultModules ++ [
          #     ./1systems/nas1/physical.nix
          #   ];
          # };

          # rpi2 = nixpkgs.lib.nixosSystem {
          #   system = "aarch64-linux";
          #   modules = defaultModules ++ [
          #     ./1systems/rpi2/physical.nix
          #   ];
          # };

          # rpi3 = nixpkgs.lib.nixosSystem {
          #   system = "aarch64-linux";
          #   modules = defaultModules ++ [
          #     ./1systems/rpi3
          #   ];
          # };

          rpi4 = nixpkgs.lib.nixosSystem
            {
              system = "aarch64-linux";
              modules = defaultModules ++ [
                nixos-hardware.nixosModules.raspberry-pi-4
                ./1systems/rpi4
                { _module.args.nixinate = { host = "rpi4.fritz.box"; sshUser = "root"; buildOn = "remote"; }; }
              ];
            };

          # ws1 = nixpkgs.lib.nixosSystem {
          #   system = "x86_64-linux";
          #   modules = defaultModules ++ [
          #     ./1systems/ws1/physical.nix
          #   ];
          #   specialArgs = { inherit nixos-hardware home-manager pkgOverrides; };
          # };

          # pine2 = nixpkgs.lib.nixosSystem {
          #   system = "aarch64-linux";
          #   modules = defaultModules ++ [
          #     ./1systems/pine2/physical.nix
          #   ];
          # };

          # pine2_cross = nixpkgs.lib.nixosSystem {
          #   system = "x86_64-linux";
          #   modules = [
          #     ./1systems/pine2/physical.nix
          #     ({ lib, ... }: {
          #       nixpkgs.crossSystem = lib.systems.examples.aarch64-multiplatform;
          #     })
          #   ];
          # };

          # # run `nix build .#nixosConfigurations.pine2_sdimage.config.syspem.build.sdImage` to build image
          # pine2_sdimage = nixpkgs.lib.nixosSystem {
          #   system = "aarch64-linux";
          #   modules = [
          #     ({ config, lib, modulesPath, pkgs, ... }: {
          #       imports = [
          #         ./2configs/sd-image.nix
          #         ./2configs/hw/pinephone-pro
          #         (modulesPath + "/profiles/installation-device.nix")
          #       ];

          #       environment.systemPackages = with pkgs; [
          #         foot.terminfo
          #         file
          #         gptfdisk
          #         cryptsetup
          #         f2fs-tools
          #         xfsprogs.bin
          #         gitMinimal
          #       ];

          #       nix.package = pkgs.nixFlakes;

          #       users.users.nixos.openssh.authorizedKeys.keys = (import ./2configs/users/ssh-pubkeys.nix).authorizedKeys_enno;
          #       users.users.root.openssh.authorizedKeys.keys = (import ./2configs/users/ssh-pubkeys.nix).authorizedKeys_enno;

          #       sdImage = {
          #         populateFirmwareCommands = "";
          #         populateRootCommands = ''
          #           mkdir -p ./files/boot
          #           ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
          #         '';
          #       };

          #       networking = {
          #         useNetworkd = true;
          #         useDHCP = false;
          #         wireless.enable = false;
          #         wireless.iwd.enable = true;
          #         networkmanager = {
          #           enable = true;
          #           dns = "systemd-resolved";
          #           wifi.backend = "iwd";
          #         };
          #       };
          #       services.resolved.enable = true;
          #       services.resolved.dnssec = "false";
          #     })
          #   ];
          # };

          mb4-nixos =
            nixpkgs.lib.nixosSystem
              {
                system = "aarch64-linux";
                modules = defaultModules ++ [
                  ./2configs/ff.nix
                  #./2configs/rpi-netboot.nix
                  ./2configs/utm-i3.nix
                  ./2configs/utmvm.nix
                  ./2configs/vm-efi-xfs.nix
                  {
                    time.timeZone = "Europe/Berlin";
                    networking.hostName = "mb4-nixos";
                    system.stateVersion = "22.05";
                    virtualisation.docker = { enable = true; enableOnBoot = false; };

                    fileSystems."/home/enno/Downloads-Keep" = {
                      device = "//192.168.67.1/Downloads-Keep";
                      fsType = "cifs";
                      options = [
                        "x-systemd.automount"
                        "noauto"
                        "x-systemd.idle-timeout=60"
                        "x-systemd.device-timeout=5s"
                        "x-systemd.mount-timeout=5s"
                        "credentials=/home/enno/.smb-secrets"
                        "uid=1000"
                        "gid=100"
                      ];
                    };

                    containers.ff = {
                      autoStart = true;
                      ephemeral = true;
                      macvlans = [ "bat0" ];
                      bindMounts = {
                        "/home/enno/Downloads-Keep" = { hostPath = "/home/enno/Downloads-Keep"; isReadOnly = false; };
                      };
                      config = { config, pkgs, ... }: {
                        system.stateVersion = "22.11";

                        environment.systemPackages = with pkgs; [ rtorrent ];

                        networking = {
                          useDHCP = false;
                          interfaces.mv-bat0.useDHCP = true;
                        };

                        # Manually configure nameserver. Using resolved inside the container seems to fail
                        # currently
                        environment.etc."resolv.conf".text = "nameserver 8.8.8.8";

                        services.getty.autologinUser = "root";
                      };
                    };

                    _module.args.nixinate = {
                      host = "192.168.67.3";
                      sshUser = "enno";
                      buildOn = "remote";
                    };
                  }
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
                          ./2configs/home/firefox.nix
                          ./2configs/home/fish.nix
                          ./2configs/home/fonts.nix
                          ./2configs/home/git.nix
                          #./2configs/home/gpg.nix
                          ./2configs/home/neovim.nix
                          ./2configs/home/packages.nix
                          ./2configs/home/ssh.nix
                          ./2configs/home/alacritty.nix
                          ./2configs/home/chromium.nix
                          ./2configs/home/i3.nix
                          ./2configs/home/i3status.nix
                          ./2configs/home/xdg.nix
                        ];
                        nixpkgs.config = {
                          allowUnfree = true;
                          allowUnfreePredicate = (pkg: true); # https://github.com/nix-community/home-manager/issues/2942
                          packageOverrides = pkgOverrides pkgs;
                        };

                        services.syncthing.enable = true;
                      };
                  })
                ];
                specialArgs = { inherit nixpkgs; };
              };

          hyperv_x86 = nixpkgs.lib.nixosSystem
            {
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

          vbox_x86 = nixpkgs.lib.nixosSystem
            {
              system = "x86_64-linux";
              modules = defaultModules ++ [
                ./2configs/vbox.nix
                ./2configs/utm-i3.nix
              ];
            };

          ws2-nixos = nixpkgs.lib.nixosSystem
            {
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

          utmvm_x86 = nixpkgs.lib.nixosSystem
            {
              system = "x86_64-linux";
              modules = defaultModules ++ [
                ./2configs/utmvm.nix
                ./2configs/vm-efi-xfs.nix
              ];
            };

          utmvm_i3_x86 = nixpkgs.lib.nixosSystem
            {
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

          utmvm = nixpkgs.lib.nixosSystem
            {
              system = "aarch64-linux";
              modules = defaultModules ++ [
                ./2configs/utmvm.nix
                ./2configs/vm-efi-xfs.nix
              ];
            };

          utmvm_qcow = nixpkgs.lib.nixosSystem
            {
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
            pkgs = nixpkgs.legacyPackages.aarch64-linux;

            modules = [
              ({ config, lib, pkgs, ... }: {
                home = {
                  username = "enno";
                  homeDirectory = "/home/enno";
                  stateVersion = "22.05";
                };

                imports = desktopImports ++ [
                  ./2configs/home/alacritty.nix
                  ./2configs/home/chromium.nix
                  ./2configs/home/i3.nix
                  ./2configs/home/i3status.nix
                  ./2configs/home/xdg.nix
                ];

                nixpkgs.config = {
                  allowUnfree = true;
                  allowUnfreePredicate = (pkg: true); # https://github.com/nix-community/home-manager/issues/2942
                  packageOverrides = pkgOverrides pkgs;
                };

                services.syncthing.enable = true;
              })
            ];
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
            pkgs = nixpkgs-unstable.legacyPackages.aarch64-darwin;

            modules = [
              ({ config, lib, pkgs, ... }: {
                home = {
                  username = "enno";
                  homeDirectory = "/Users/enno";
                  stateVersion = "21.11";
                };

                imports = desktopImports ++ [
                  #./2configs/home/email.nix
                  ./2configs/home/alacritty.nix
                  ./2configs/home/darwin-defaults.nix
                  ./2configs/home/paperless.nix
                ];

                nixpkgs.config = {
                  allowUnfree = true;
                  allowUnfreePredicate = (pkg: true); # https://github.com/nix-community/home-manager/issues/2942
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
                    "${homeDirectory}/.Trash"
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
                    repo = "ssh://borg-mb4@rpi4.fritz.box/./";
                    compression = "zstd,3";
                    postCreate = "${pkgs.borg2prom}/bin/borg2prom $archiveName rpi4";
                  };
                };
              })
            ];
          };

          macos-luisa = home-manager.lib.homeManagerConfiguration
            {
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

                home.packages = with pkgs;[ home-manager git nnn ];

                services.syncthing.enable = true;

                ptsd.borgbackup.jobs = with config.home; let
                  encryption = {
                    mode = "repokey-blake2";
                    passCommand = "cat ${homeDirectory}/.borgkey";
                  };
                  environment.BORG_RSH = "ssh -i ${homeDirectory}/.ssh/nwbackup.id_ed25519";
                  exclude = [
                    "${homeDirectory}/.cache"
                    "${homeDirectory}/.Trash"
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
