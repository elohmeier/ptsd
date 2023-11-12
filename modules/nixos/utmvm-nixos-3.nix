({ lib, pkgs, ... }: {
  system.stateVersion = "22.11";
  nixpkgs.hostPlatform = "aarch64-linux";
  systemd.network.wait-online.timeout = 0;

  # match macos ids
  # users.groups.lp.gid = lib.mkForce 1020;
  # users.groups.staff.gid = 20;
  # users.users.mainUser = {
  #   group = "staff";
  #   homeMode = "700";
  #   isNormalUser = false;
  #   isSystemUser = true;
  #   uid = 502;
  # };

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

  services.getty.autologinUser = "gordon";

  virtualisation.docker = { enable = true; enableOnBoot = false; };

  virtualisation.rosetta.enable = true;

  nix.settings = {
    extra-platforms = [ "x86_64-linux" ];
    extra-sandbox-paths = [ "/run/rosetta" "/run/binfmt" ];
  };

  environment.systemPackages = with pkgs; [
    dnsutils
    espeak-ng
    libinput
    openfortivpn
  ];

  services.xserver = {
    displayManager.lightdm = {
      autoLogin = {
        enable = true;
        user = "gordon";
      };
    };
  };

  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.config.allowUnfree = true;

  # ignore UTMs supplied DNS server (somehow not responding)
  systemd.network.networks.eth = {
    dhcpV4Config.UseDNS = false;
    dhcpV6Config.UseDNS = false;
    networkConfig.DNS = [
      "8.8.8.8"
      "2001:4860:4860::8888"
    ];
  };

  networking = {
    firewall.trustedInterfaces = [ "ppp0" ];
  };

  # https://github.com/adrienverge/openfortivpn/issues/1076
  environment.etc."ppp/options".text = "ipcp-accept-remote";
})
