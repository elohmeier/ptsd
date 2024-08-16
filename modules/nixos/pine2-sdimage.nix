# run `nix build .#nixosConfigurations.pine2_sdimage.config.syspem.build.sdImage` to build image
(
  {
    config,
    modulesPath,
    pkgs,
    ...
  }:
  {
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

    users.users.nixos.openssh.authorizedKeys.keys =
      (import ./2configs/users/ssh-pubkeys.nix).authorizedKeys_enno;
    users.users.root.openssh.authorizedKeys.keys =
      (import ./2configs/users/ssh-pubkeys.nix).authorizedKeys_enno;

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
  }
)
