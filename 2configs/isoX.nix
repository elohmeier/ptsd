# Use "mk-iso" to build

{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
    <nixpkgs/nixos/modules/profiles/all-hardware.nix>
    <nixpkgs/nixos/modules/profiles/base.nix>

    # Enable devices which are usually scanned, because we don't know the
    # target system.
    <nixpkgs/nixos/modules/installer/scan/detected.nix>
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>

    # Allow "nixos-rebuild" to work properly by providing
    # /etc/nixos/configuration.nix.
    <nixpkgs/nixos/modules/profiles/clone-config.nix>

    # Include a copy of Nixpkgs so that nixos-install works out of
    # the box.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>

    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/baseX.nix>
    <ptsd/2configs/tor-ssh.nix>

    <secrets-shared/nwsecrets.nix>
    <ptsd/2configs/hw/macbook9_1.nix>

    <home-manager/nixos>
  ];

  # ISO naming.
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";

  isoImage.volumeID = lib.substring 0 11 "NIXOS_ISO";

  # EFI booting
  isoImage.makeEfiBootable = true;

  # USB booting
  isoImage.makeUsbBootable = true;

  # Add Memtest86+ to the CD.
  boot.loader.grub.memtest86.enable = true;

  system.stateVersion = lib.mkDefault "20.03";

  security.sudo.wheelNeedsPassword = lib.mkForce false;

  # Tell the Nix evaluator to garbage collect more aggressively.
  # This is desirable in memory-constrained environments that don't
  # (yet) have swap set up.
  environment.variables.GC_INITIAL_HEAP_SIZE = "1M";

  # Make the installer more likely to succeed in low memory
  # environments.  The kernel's overcommit heustistics bite us
  # fairly often, preventing processes such as nix-worker or
  # download-using-manifests.pl from forking even if there is
  # plenty of free memory.
  boot.kernel.sysctl."vm.overcommit_memory" = "1";

  # To speed up installation a little bit, include the complete
  # stdenv in the Nix store on the CD.
  system.extraDependencies = with pkgs;
    [
      stdenv
      stdenvNoCC # for runCommand
      busybox
      jq # for closureInfo
    ];

  # Show all debug messages from the kernel but don't log refused packets
  # because we have the firewall enabled. This makes installs from the
  # console less cumbersome if the machine has a public IP.
  networking.firewall.logRefusedConnections = lib.mkDefault false;

  console.keyMap = "de-latin1";

  networking.networkmanager.enable = true;
  networking.wireless.enable = false;

  systemd.user.services.nm-applet = {
    description = "Network Manager applet";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    path = [ pkgs.dbus ];
    serviceConfig = {
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
      RestartSec = 3;
      Restart = "always";
    };
  };

  home-manager = {
    users.mainUser = { pkgs, ... }:
      {
        imports = [
          <ptsd/2configs/home>
          <ptsd/2configs/home/gpg.nix>
          <ptsd/2configs/home/xsession-i3.nix>
        ];
        nixpkgs.config.allowUnfree = true;
      };
  };

  #  boot.kernelParams = [ "console=tty0" "console=ttyS0,115200n8" ];
}
