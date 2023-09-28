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

