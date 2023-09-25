{ pkgs, ... }: {

  imports = [
    ../../2configs/rpi3b_4.nix
    ./home-assistant.nix
  ];

  users.users.root.openssh.authorizedKeys.keys =
    let sshPubKeys = import ../../2configs/users/ssh-pubkeys.nix; in sshPubKeys.authorizedKeys_enno;

  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";
  networking.firewall.trustedInterfaces = [ "eth0" "wlan0" "end0" ];
  networking.hostName = "rpi4";
  ptsd.tailscale.enable = true;
  ptsd.tailscale.cert.enable = true;
  services.getty.autologinUser = "root";
  services.openssh.enable = true;
  system.stateVersion = "23.11";

  networking.firewall.extraCommands = ''
    iptables -t nat -A PREROUTING -p tcp --dport 445 -j DNAT --to-destination 100.92.45.113:445
    iptables -t nat -I POSTROUTING -d 100.92.45.113 -p tcp --dport 445 -j MASQUERADE
  '';

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  environment.systemPackages = with pkgs; [
    btop
    tcpdump
  ];

  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-partuuid/d30fc381-989f-4eb5-94da-bd66e56a22ed";
    fsType = "ext4";
    options = [
      "commit=120"
      "noatime"
      "nodev"
      "noexec"
      "nofail"
      "nosuid"
    ];
  };

  programs.fish.enable = true;

  services.borgbackup.repos =
    let
      cfg = hostname: {
        authorizedKeysAppendOnly = [ (import ../../2configs/universe.nix).hosts."${hostname}".borg.pubkey ];
        path = "/mnt/backup/borg/${hostname}";
        inherit ((import ../../2configs/universe.nix).hosts."${hostname}".borg) quota;
        user = "borg-${hostname}";
      };
    in
    {
      htz1 = cfg "htz1";
      htz2 = cfg "htz2";
      mb3 = cfg "mb3";
      mb4 = cfg "mb4";
      convexio_prod = cfg "convexio_prod";
    };

  systemd.services.borgbackup-repo-mb4.serviceConfig.RequiresMountsFor = "/mnt/backup";
  systemd.services.borgbackup-repo-mb3.serviceConfig.RequiresMountsFor = "/mnt/backup";
  systemd.services.borgbackup-repo-htz2.serviceConfig.RequiresMountsFor = "/mnt/backup";
  systemd.services.borgbackup-repo-htz1.serviceConfig.RequiresMountsFor = "/mnt/backup";
  systemd.services.borgbackup-repo-convexio_prod.serviceConfig.RequiresMountsFor = "/mnt/backup";

  # pin uids (not persisted)
  users.groups.borg.gid = 994;
  users.users.borg-mb4.uid = 991;
  users.users.borg-mb3.uid = 992;
  users.users.borg-htz2.uid = 993;
  users.users.borg-htz1.uid = 994;
  users.users.borg-convexio_prod.uid = 995;
}
