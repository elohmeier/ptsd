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

