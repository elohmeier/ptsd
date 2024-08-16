{
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./netcfg.nix
    # ./prometheus-node.nix
  ];

  boot = {
    # cleanTmpDir = true;
    tmp.cleanOnBoot = true;
    initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "xen_blkfront"
    ] ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [ "vmw_pvscsi" ];
    initrd.kernelModules = [ "nvme" ];

    loader.grub = {
      efiSupport = pkgs.stdenv.hostPlatform.isAarch64;
      efiInstallAsRemovable = pkgs.stdenv.hostPlatform.isAarch64;
      device = if pkgs.stdenv.hostPlatform.isx86_64 then "/dev/sda" else "nodev";
    };
  };

  documentation.nixos.enable = false;
  documentation.man.enable = false;

  fileSystems = {
    "/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };
    "/boot" = lib.mkIf (pkgs.stdenv.hostPlatform.isAarch64) {
      device = "/dev/sda15";
      fsType = "vfat";
    };
  };

  services.eternal-terminal.enable = true;

  networking = {
    domain = "";
    firewall = {
      allowedTCPPorts = [ 2022 ];
      logRefusedConnections = false;
    };
    useNetworkd = true;
  };

  programs.command-not-found.enable = false;
  services.hcloud-netcfg.enable = lib.mkDefault true;
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  system.stateVersion = "23.05";
  time.timeZone = "UTC";
  users.mutableUsers = false;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7OXq7COvJxoRQ2AQdo0HTJCITC6cPIZN/zs8XwCk4b enno@mb4"
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLAUxgxfb28NybtTCWjRUKuDvbNai4fZzeIIG4/YTAWIO6VTklmD6HiEVrG4ASRfaPv0Py48POGliXF+7gDU0j0= enno@secretive.mb4.local"
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDrRFPTI7Dspol0HbM96RyGpUfvkC13IkCb4f6BFeZifRV5TOdocZQXKazCN8yBSeXPxIP5GVKv0vNglL1QMcP4=" # tp3
  ];
  users.users.root.shell = pkgs.fish;

  programs.fish = {
    enable = true;
    useBabelfish = true;
    interactiveShellInit = ''
      set -U fish_greeting
    '';
    shellAliases.vim = "nvim";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  environment.systemPackages = with pkgs; [
    btop
    ncdu
    parted
    tmux
  ];

  nix.extraOptions = "experimental-features = nix-command flakes";
}
