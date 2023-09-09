{
  description = "ptsd";

  inputs = {
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:elohmeier/home-manager/master-darwin";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs-unstable";
    lanzaboote.inputs.flake-utils.follows = "flake-utils";
    lanzaboote.url = "github:nix-community/lanzaboote/v0.3.0";
    nixinate.inputs.nixpkgs.follows = "nixpkgs";
    nixinate.url = "github:elohmeier/nixinate";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-unstable-rpi4.url = "github:elohmeier/nixpkgs/6afb867d477dd0bc61f56a7c2cc514673f5f75d2";
    nixpkgs-unstable.url = "github:elohmeier/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:elohmeier/nixpkgs/nixos-23.05";
  };

  outputs =
    { self
    , disko
    , flake-utils
    , home-manager
    , lanzaboote
    , nixinate
    , nixos-hardware
    , nixpkgs
    , nixpkgs-unstable
    , nixpkgs-unstable-rpi4
    , ...
    }:

    let
      pkgOverrides = pkgs:
        let pkgs_master = import nixpkgs-unstable { config.allowUnfree = true; inherit (pkgs) system; }; in
        super: (import ./5pkgs pkgs pkgs_master nixpkgs super);
    in
    flake-utils.lib.eachDefaultSystem
      (system:
      {
        packages =
          let
            pkgs = import nixpkgs-unstable {
              config.allowUnfree = true; inherit system;
              config.packageOverrides = pkgOverrides self;
            };
          in
          {
            deploy-rpi4_scangw = pkgs.writeShellScriptBin "deploy-rpi4_scangw" ''
              echo "building..."
              nix copy --to ssh://root@rpi4.fritz.box ${self.nixosConfigurations.rpi4_scangw.config.system.build.toplevel}
              echo "activating..."
              ssh -t root@rpi4.fritz.box "${self.nixosConfigurations.rpi4_scangw.config.system.build.toplevel}/bin/switch-to-configuration switch"
            '';
          };
      })
    // {
      apps = nixinate.nixinate.aarch64-darwin self;

      overlay = import ./5pkgs/overlay.nix;

      nixosConfigurations =
        let
          defaultModules = nixPath: [
            ./3modules
            ({ pkgs, ... }:
              {
                nix.nixPath = [ "nixpkgs=${nixPath}" ];
                nixpkgs.config = { allowUnfree = true; packageOverrides = pkgOverrides pkgs; };
              })
          ];
        in
        {
          rescue-rpi4 = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              nixos-hardware.nixosModules.raspberry-pi-4
              ./2configs/rescue.nix
              ./2configs/hw/rpi3b_4.nix
              ({ config, pkgs, ... }:
                {
                  # the result can be copied to a fat32-formatted sd card
                  system.build.sdroot =
                    let
                      configTxt = pkgs.writeText "config.txt" ''
                        [pi4]
                        kernel=u-boot-rpi4.bin
                        enable_gic=1
                        armstub=armstub8-gic.bin

                        # Otherwise the resolution will be weird in most cases, compared to
                        # what the pi3 firmware does by default.
                        disable_overscan=1

                        # Supported in newer board revisions
                        arm_boost=1

                        [all]
                        # Boot in 64-bit mode.
                        arm_64bit=1

                        # U-Boot needs this to work, regardless of whether UART is actually used or not.
                        # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
                        # a requirement in the future.
                        enable_uart=1
      
                        # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
                        # when attempting to show low-voltage or overtemperature warnings.
                        avoid_warnings=1
                      '';
                      toplevel-squashfs = pkgs.runCommand "toplevel-netboot" { } ''
                        mkdir $out
                        cp ${config.system.build.toplevel}/{kernel-params,nixos-version} $out/
                        ln -s ${config.system.build.kernel}/Image $out/kernel
                        ln -s ${config.system.build.netbootRamdisk}/initrd $out/initrd
                        ln -s ${config.hardware.deviceTree.package} $out/dtbs
                      '';
                    in
                    pkgs.runCommand "rescue-rpi4-sdroot" { } ''
                      mkdir -p $out
                      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/{bootcode.bin,fixup*.dat,start*.elf,bcm2711-rpi-4-b.dtb} $out/
                      cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin $out/
                      cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin $out/u-boot-rpi4.bin
                      cp ${configTxt} $out/config.txt
                      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${toplevel-squashfs} -d $out
                    '';


                  # see https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
                  nixpkgs.overlays = [
                    (_final: super: {
                      makeModulesClosure = x:
                        super.makeModulesClosure (x // { allowMissing = true; });
                    })
                  ];

                })
            ];
          };

          macvm = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = defaultModules ++ [
              home-manager.nixosModule
              ({ config, lib, pkgs, modulesPath, ... }: {
                imports = [
                  "${modulesPath}/virtualisation/qemu-vm.nix"
                  ./2configs/users/mainuser.nix
                  # ./2configs/devenv.nix # TODO
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
                    [
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

          tp3 = nixpkgs-unstable.lib.nixosSystem {
            system = "x86_64-linux";
            modules = (defaultModules nixpkgs-unstable) ++ [
              home-manager.nixosModule
              disko.nixosModules.disko
              lanzaboote.nixosModules.lanzaboote
              ./2configs/networkmanager.nix
              ./2configs/nix-persistent.nix
              ./2configs/users
              ./2configs
              ./2configs/fish.nix
              ({ config, lib, pkgs, ... }: {
                system.stateVersion = "23.11";
                networking.hostName = "tp3";
                # services.getty.autologinUser = config.users.users.mainUser.name;
                ptsd.tailscale.enable = true;
                disko.devices = import ./2configs/disko/luks-lvm-immutable.nix {
                  inherit lib;
                };
                fileSystems = {
                  "/" = {
                    fsType = "tmpfs";
                    options = [ "size=1G" "mode=1755" ];
                  };
                };
                swapDevices = [
                  { device = "/dev/pool/swap"; }
                ];
                time.timeZone = "Europe/Berlin";
                services.pipewire = {
                  enable = true;
                  alsa.enable = true;
                  alsa.support32Bit = true;
                  pulse.enable = true;
                };
                services.fwupd.enable = true;
                boot = {
                  kernelParams = [
                    "mitigations=off" # make linux fast again
                    "acpi_backlight=native" # force thinkpad_acpi driver
                    "amd_pstate=active"
                  ];

                  resumeDevice = "/dev/pool/swap";

                  lanzaboote = {
                    enable = true;
                    pkiBundle = "/nix/persistent/etc/secureboot";
                  };

                  loader = {
                    systemd-boot.enable = lib.mkForce false; # replaced by lanzaboote
                    systemd-boot.editor = false;
                    efi.canTouchEfiVariables = true;
                  };
                  initrd = {
                    availableKernelModules = [
                      "ahci"
                      "ata_piix"
                      "ehci_pci"
                      "hid_microsoft"
                      "ntfs3"
                      "nvme"
                      "ohci_pci"
                      "sd_mod"
                      "sr_mod"
                      "uhci_hcd"
                      "usb_storage"
                      "usbhid"
                      "xhci_pci"
                    ];

                    kernelModules = [
                      "amdgpu"
                    ];

                    systemd = {
                      enable = true;
                      emergencyAccess = true;
                      network.wait-online.timeout = 0;
                    };
                  };
                  kernelPackages = pkgs.linuxPackages_latest;
                  kernelModules = [ "kvm-amd" "acpi_call" ];
                  extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
                };
                systemd.network.wait-online.timeout = 0;
                services.fstrim.enable = true;
                services.xserver = {
                  enable = true;
                  desktopManager = {
                    xterm.enable = false;
                    xfce.enable = true;
                  };
                  displayManager.defaultSession = "xfce";
                  displayManager.lightdm = {
                    background = "#008080";
                    greeters.gtk = {
                      cursorTheme = {
                        package = pkgs.chicago95;
                        name = "Chicago95 Animated Hourglass Cursors";
                      };
                      iconTheme = {
                        package = pkgs.chicago95;
                        name = "Chicago95";
                      };
                      theme = {
                        package = pkgs.chicago95;
                        name = "Chicago95";
                      };
                    };
                  };
                  videoDrivers = [ "modesetting" ];
                  libinput.enable = true;
                  libinput.touchpad.naturalScrolling = true;
                  libinput.mouse.naturalScrolling = true;
                  xkbOptions = "eurosign:e,terminate:ctrl_alt_bksp,compose:ralt";
                };
                programs.thunar = {
                  enable = true;
                  plugins = [ pkgs.xfce.thunar-archive-plugin ];
                };
                programs.steam.enable = true;
                hardware.opengl = {
                  enable = true;
                  driSupport = true;
                  driSupport32Bit = true;
                  extraPackages = with pkgs; [
                    amdvlk
                    rocm-opencl-icd
                    rocm-opencl-runtime
                  ];
                  extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
                };

                boot.plymouth = {
                  enable = true;
                  # theme = "Chicago95";
                  # themePackages = [ pkgs.chicago95 ];
                };
                specialisation.plymouth95.configuration = {
                  boot.plymouth = {
                    enable = true;
                    theme = "Chicago95";
                    themePackages = [ pkgs.chicago95 ];
                  };
                };

                console.font = "${pkgs.spleen}/share/consolefonts/spleen-8x16.psfu";
                powerManagement.cpuFreqGovernor = "schedutil";
                powerManagement.powertop.enable = true;
                hardware.cpu.amd.updateMicrocode = true;
                environment.systemPackages = [
                  pkgs.alsa-utils
                  pkgs.btop
                  pkgs.chicago95
                  pkgs.file
                  pkgs.git
                  pkgs.glxinfo
                  pkgs.gnome.gnome-disk-utility
                  pkgs.home-manager
                  pkgs.libcanberra-gtk3
                  pkgs.libinput
                  pkgs.pavucontrol
                  pkgs.powertop
                  pkgs.python3 # required by proton (steam)
                  pkgs.sbctl
                  pkgs.vulkan-tools
                  pkgs.xclip
                  pkgs.xfce.xfce4-pulseaudio-plugin
                  pkgs.xfce.xfce4-fsguard-plugin
                  pkgs.xsel
                ];
                fonts.packages = [ pkgs.chicago95 ];
                virtualisation.docker = {
                  enable = true;
                  enableOnBoot = false;
                };
                systemd.services.tailscaled.wantedBy = lib.mkForce [ ]; # manual start to reduce battery usage (frequent wakeups)

                security.tpm2 = {
                  enable = true;
                  pkcs11.enable = true;
                  tctiEnvironment.enable = true;
                };
              })
            ];
          };

          tp4 = nixpkgs.lib.nixosSystem
            {
              system = "x86_64-linux";
              modules = defaultModules ++ [
                home-manager.nixosModule
                ./2configs
                ./2configs/generic-desktop.nix
                ./2configs/generic-disk.nix
                ./2configs/generic.nix

                ({ config, pkgs, ... }: {
                  system.stateVersion = "22.11";

                  boot.initrd.services.lvm.enable = true;

                  networking.hostName = "tp4";

                  boot.loader.systemd-boot.configurationLimit = 1;

                  fileSystems."/nix".device = "/dev/vg/nix";

                  fileSystems."/home" = {
                    device = "/dev/vg/home";
                    fsType = "ext4";
                    options = [ "nosuid" "nodev" ];
                  };

                  nixpkgs.hostPlatform = "x86_64-linux";

                  services.getty.autologinUser = config.users.users.mainUser.name;

                  programs.fish.interactiveShellInit = "echo This is an unencrypted device. Do not store any private data.";

                  nixpkgs.config.permittedInsecurePackages = [
                    "electron-19.0.7"
                  ];

                  boot.blacklistedKernelModules = [ "nouveau" ];

                  ptsd.generic.nvidia.enable = false;
                  ptsd.generic.amdgpu.enable = false;

                  hardware.nvidia = {
                    package = config.boot.kernelPackages.nvidiaPackages.legacy_390;
                  };

                  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

                  hardware.bumblebee.enable = true;

                  hardware.opengl = {
                    extraPackages = with pkgs; [
                      intel-media-driver
                      vaapiIntel
                      vaapiVdpau
                      libvdpau-va-gl
                    ];
                    extraPackages32 = with pkgs.pkgsi686Linux; [
                      vaapiIntel
                    ];
                  };

                  boot.kernelPackages = pkgs.linuxPackages_latest.extend (selfLinux: superLinux: {
                    nvidia_x11 = superLinux.nvidia_x11_legacy390;
                  });

                  nixpkgs.config.packageOverrides = pkgs: {
                    bumblebee = pkgs.bumblebee.override {
                      nvidia_x11 = pkgs.linuxPackages_latest.nvidia_x11_legacy390;
                    };
                    primusLib = pkgs.primusLib.override {
                      nvidia_x11 = pkgs.linuxPackages_latest.nvidia_x11_legacy390.override { libsOnly = true; };
                    };
                  };
                })
                {
                  _module.args.nixinate = {
                    host = "tp4.fritz.box";
                    sshUser = "root";
                    buildOn = "remote";
                  };
                }
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
              modules = (defaultModules nixpkgs) ++ [
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

          rpi4_scangw = nixpkgs-unstable-rpi4.lib.nixosSystem
            {
              system = "aarch64-linux";
              modules = (defaultModules nixpkgs-unstable-rpi4) ++ [
                ./1systems/rpi4_scangw
                nixos-hardware.nixosModules.raspberry-pi-4
              ];
            };

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
                      device = "//192.168.70.1/Downloads-Keep";
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
                      config = { pkgs, ... }: {
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
                      host = "192.168.70.2";
                      sshUser = "enno";
                      buildOn = "remote";
                    };
                  }
                  home-manager.nixosModule
                  (_: {
                    system.stateVersion = "22.05";
                    virtualisation.docker = { enable = true; enableOnBoot = false; };

                    #home-manager.useGlobalPkgs = true;
                    #home-manager.users.mainUser = { config, lib, pkgs, nixosConfig, ... }:
                    #  {
                    #    home.stateVersion = "22.05";
                    #    imports = [
                    #      ./2configs/home
                    #      ./2configs/home/firefox.nix
                    #      ./2configs/home/fish.nix
                    #      ./2configs/home/fonts.nix
                    #      ./2configs/home/git.nix
                    #      #./2configs/home/gpg.nix
                    #      ./2configs/home/neovim.nix
                    #      ./2configs/home/packages.nix
                    #      ./2configs/home/ssh.nix
                    #      ./2configs/home/alacritty.nix
                    #      ./2configs/home/chromium.nix
                    #      ./2configs/home/i3.nix
                    #      ./2configs/home/i3status.nix
                    #      ./2configs/home/xdg.nix
                    #    ];
                    #    nixpkgs.config = {
                    #      allowUnfree = true;
                    #      allowUnfreePredicate = (pkg: true); # https://github.com/nix-community/home-manager/issues/2942
                    #      packageOverrides = pkgOverrides pkgs;
                    #    };

                    #    services.syncthing.enable = true;
                    #  };
                  })
                ];
                specialArgs = { inherit nixpkgs; };
              };

          generic_aarch64 = nixpkgs.lib.nixosSystem
            {
              system = "aarch64-linux";
              modules = defaultModules ++ [
                ./2configs/generic.nix
                ./2configs/generic-disk.nix
                {
                  system.stateVersion = "22.11";
                  nixpkgs.hostPlatform = "aarch64-linux";
                }
                { _module.args.nixinate = { host = "192.168.69.5"; sshUser = "root"; buildOn = "remote"; }; }
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

          utmvm_nixos_2 = nixpkgs.lib.nixosSystem
            {
              system = "aarch64-linux";
              modules = defaultModules ++ [
                home-manager.nixosModule
                ./2configs/generic.nix
                ./2configs/generic-disk.nix
                ./2configs/generic-desktop.nix
                ({ lib, ... }: {
                  system.stateVersion = "22.11";
                  nixpkgs.hostPlatform = "aarch64-linux";

                  # match macos ids
                  users.groups.lp.gid = lib.mkForce 1020;
                  users.groups.staff.gid = 20;
                  users.users.mainUser = {
                    group = "staff";
                    homeMode = "700";
                    isNormalUser = false;
                    isSystemUser = true;
                    uid = 502;
                  };

                  fileSystems."/home/gordon/repos" = {
                    device = "192.168.70.1:/Users/enno/repos";
                    fsType = "nfs";
                    options = [
                      "x-systemd.automount"
                      "noauto"
                      "nfsvers=3"
                    ];
                  };

                  services.getty.autologinUser = "root";

                  # not supported (QEMU VM)
                  # virtualisation.rosetta.enable = true;
                })
                { _module.args.nixinate = { host = "192.168.70.4"; sshUser = "root"; buildOn = "remote"; }; }
              ];
            };

          utmvm_nixos_3 = nixpkgs.lib.nixosSystem
            {
              system = "aarch64-linux";
              modules = defaultModules ++ [
                home-manager.nixosModule
                ./2configs/generic.nix
                ./2configs/generic-disk.nix
                # ./2configs/generic-desktop.nix
                ({ lib, pkgs, ... }: {
                  system.stateVersion = "22.11";
                  nixpkgs.hostPlatform = "aarch64-linux";
                  systemd.services.systemd-networkd-wait-online.enable = false;
                  # match macos ids
                  users.groups.lp.gid = lib.mkForce 1020;
                  users.groups.staff.gid = 20;
                  users.users.mainUser = {
                    group = "staff";
                    homeMode = "700";
                    isNormalUser = false;
                    isSystemUser = true;
                    uid = 502;
                  };

                  # fileSystems."/home/gordon/repos" = {
                  #   device = "192.168.73.1:/Users/enno/repos";
                  #   fsType = "nfs";
                  #   options = [
                  #     "x-systemd.automount"
                  #     "noauto"
                  #     "nfsvers=3"
                  #     "x-systemd.mount-timeout=5s"
                  #   ];
                  # };

                  # mb4 remote build
                  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINW7keKHT6oXCcjR7vWDufiuCb/JCK+ATJO+ZFpLYH1w root@mb4.fritz.box" ];

                  services.getty.autologinUser = "root";

                  virtualisation.docker = { enable = true; enableOnBoot = false; };

                  virtualisation.rosetta.enable = true;

                  nix.settings = {
                    extra-platforms = [ "x86_64-linux" ];
                    extra-sandbox-paths = [ "/run/rosetta" "/run/binfmt" ];
                  };

                  environment.systemPackages = with pkgs; [ libinput openfortivpn espeak-ng ];
                  services.xserver.layout = "us";
                  services.xserver.libinput.enable = true;
                  services.xserver.libinput.mouse.naturalScrolling = true;
                  console.keyMap = "us";
                  i18n.defaultLocale = "en_US.UTF-8";
                })
                { _module.args.nixinate = { host = "192.168.74.3"; sshUser = "root"; buildOn = "remote"; }; }
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
                (_: {
                  system.stateVersion = "22.05";
                  virtualisation.docker = { enable = true; enableOnBoot = false; };

                  home-manager.useGlobalPkgs = true;
                  home-manager.users.mainUser = { config, pkgs, ... }:
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
            ./2configs/home/fish.nix
            ./2configs/home/fonts.nix
            ./2configs/home/git.nix
            ./2configs/home/gpg.nix
            ./2configs/home/neovim.nix
            ./2configs/home/packages.nix
            ./2configs/home/ssh.nix
            ./2configs/home/tmux.nix
            ./2configs/home/xdg-fixes.nix
          ];
        in
        {
          xfce95 = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;

            modules = [
              ({ config, lib, pkgs, ... }: {
                home = {
                  username = "gordon";
                  homeDirectory = "/home/gordon";
                  stateVersion = "23.05";
                };

                imports = [
                  ./2configs/home
                  # ./2configs/home/firefox.nix
                  ./2configs/home/fish.nix
                  ./2configs/home/fonts.nix
                  ./2configs/home/git.nix
                  ./2configs/home/gpg.nix
                  ./2configs/home/neovim.nix
                  ./2configs/home/packages.nix
                  ./2configs/home/ssh.nix
                  ./2configs/home/tmux.nix
                  ./2configs/home/xdg-fixes.nix
                ];

                nixpkgs.config = {
                  allowUnfree = true;
                  allowUnfreePredicate = _pkg: true; # https://github.com/nix-community/home-manager/issues/2942
                  packageOverrides = pkgOverrides pkgs;
                };

                home.packages = with pkgs; [
                  bchunk
                  firefox
                  google-chrome
                  lutris
                  samba
                  transmission-gtk
                  wine
                  winetricks
                  xarchiver
                  zathura
                ];

                programs.mpv = {
                  enable = true;
                  package = pkgs.wrapMpv (pkgs.mpv-unwrapped.override { ffmpeg_5 = pkgs.ffmpeg_5-full; }) { };
                };

                programs.ssh.extraOptionOverrides = {
                  PKCS11Provider = "/run/current-system/sw/lib/libtpm2_pkcs11.so";
                };
              })
            ];
          };

          sway_x86 = home-manager.lib.homeManagerConfiguration {
            system = "x86_64-linux";
            username = "enno";
            homeDirectory = "/home/enno";
            stateVersion = "22.05";

            configuration = { config, pkgs, ... }: {

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

            configuration = { config, pkgs, ... }: {

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
              ({ config, pkgs, ... }: {
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
                  allowUnfreePredicate = _pkg: true; # https://github.com/nix-community/home-manager/issues/2942
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

            configuration = { config, pkgs, ... }: {

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
                  sessionPath = [
                    "${config.home.homeDirectory}/.docker/bin"
                    "${config.home.homeDirectory}/.local/share/npm/bin"
                    "${config.home.homeDirectory}/repos/flutter/bin"
                    "${config.home.homeDirectory}/.pub-cache/bin"
                  ];
                  stateVersion = "21.11";
                };

                imports = desktopImports ++ [
                  #./2configs/home/email.nix
                  ./2configs/home/darwin-defaults.nix
                  ./2configs/home/paperless.nix
                ];

                nixpkgs.config = {
                  allowUnfree = true;
                  allowUnfreePredicate = _pkg: true; # https://github.com/nix-community/home-manager/issues/2942
                  packageOverrides = pkgOverrides pkgs;
                };

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
                    "${homeDirectory}/Applications"
                    "${homeDirectory}/Downloads"
                    "${homeDirectory}/Downloads-Keep"
                    "${homeDirectory}/Library"
                    "${homeDirectory}/Pictures/Photos Library.photoslibrary"
                    "${homeDirectory}/Sync/rpi4-dl" # no backup
                    "${homeDirectory}/repos/llama.cpp/models"
                    "${homeDirectory}/repos/whisper.cpp/models"
                    "${homeDirectory}/repos/convexio/.minio"
                    "${homeDirectory}/repos/convexio/.minio-prod"
                    "${homeDirectory}/repos/stable-vicuna-13b-delta/*.bin"
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
            ];
          };

          macos-luisa = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs-unstable.legacyPackages.aarch64-darwin;

            modules = [
              ({ config, pkgs, ... }: {
                home = {
                  username = "luisa";
                  homeDirectory = "/Users/luisa";
                  stateVersion = "22.05";
                };

                imports = [
                  ./2configs/home
                ];

                nixpkgs.config = {
                  allowUnfree = true;
                  packageOverrides = pkgOverrides pkgs;
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
            ];
          };
        };
    };
}

