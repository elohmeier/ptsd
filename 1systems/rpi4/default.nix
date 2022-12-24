{ config, lib, pkgs, hosts, ... }: {

  imports = [
    ../../2configs
    ../../2configs/borgbackup.nix
    ../../2configs/fish.nix
    ../../2configs/prometheus-node.nix
    ../../2configs/rpi3b_4.nix
    ../../2configs/users/enno.nix
    # ../../2configs/octoprint-rpi-mk3s.nix

    ./icloudpd.nix
    ./fluent-bit.nix
    ./fraam-gdrive-backup.nix
    ./home-assistant.nix
  ];

  services.borgbackup.jobs.hetzner.paths = [ "/mnt/syncthing" ];

  services.getty.autologinUser = "enno";
  security.sudo.wheelNeedsPassword = false;
  nix.settings.trusted-users = [ "root" "@wheel" ];
  system.stateVersion = "22.05";
  networking.hostName = "rpi4";
  environment.systemPackages = with pkgs;[ btop fscryptctl powertop ptsd-nnn ncdu tmux iperf2 ];

  services.borgbackup.repos =
    let
      cfg = hostname: {
        authorizedKeysAppendOnly = [ (import ../../2configs/universe.nix).hosts."${hostname}".borg.pubkey ];
        path = "/mnt/borgbackup/${hostname}";
        inherit ((import ../../2configs/universe.nix).hosts."${hostname}".borg) quota;
        user = "borg-${hostname}";
      };
    in
    {
      apu2 = cfg "apu2";
      htz1 = cfg "htz1";
      htz2 = cfg "htz2";
      htz3 = cfg "htz3";
      mb3 = cfg "mb3";
      mb4 = cfg "mb4";
    };

  # pin uids (not persisted)
  users.users.borg-apu2.uid = 901;
  users.users.borg-htz1.uid = 902;
  users.users.borg-htz2.uid = 903;
  users.users.borg-htz3.uid = 904;
  users.users.borg-mb3.uid = 905;
  users.users.borg-mb4.uid = 906;

  systemd.mounts =
    let
      deps = [
        "borgbackup-repo-apu2.service"
        "borgbackup-repo-htz1.service"
        "borgbackup-repo-htz2.service"
        "borgbackup-repo-htz3.service"
        "borgbackup-repo-mb3.service"
        "borgbackup-repo-mb4.service"
        "home-assistant.service"
      ];
    in
    [{
      what = "/dev/disk/by-label/usb2tb";
      where = "/mnt";
      type = "ext4";
      options = "noatime,nofail,nodev,nosuid,noexec";
      before = deps;
      requiredBy = deps;
    }];

  systemd.services.samba-smbd.wantedBy = lib.mkForce [ ];
  systemd.services.syncthing.wantedBy = lib.mkForce [ ];
  systemd.services.nginx.wantedBy = lib.mkForce [ ];

  systemd.targets.unlock-mnt = {
    description = "Unlock /mnt";
    requires = [ "unlock-mnt.service" ];
    wants = [
      "samba-smbd.service"
      "syncthing.service"
      "nginx.service"
    ];
    after = [
      "unlock-mnt.service"
      "samba-smbd.service"
      "syncthing.service"
      "nginx.service"
    ];
  };

  systemd.services.unlock-mnt = {
    description = "Unlock /mnt";
    wantedBy = [ ];
    requires = [ "mnt.mount" ];
    requiredBy = [
      "rclone-fraam-gdrive-backup.service"
      "icloudpd-enno.service"
      "icloudpd-luisa.service"
      "samba-smbd.service"
      "syncthing.service"
    ];
    before = [
      "rclone-fraam-gdrive-backup.service"
      "icloudpd-enno.service"
      "icloudpd-luisa.service"
      "samba-smbd.service"
      "syncthing.service"
    ];
    after = [ "mnt.mount" ];
    unitConfig.ConditionPathExists = "/root/key";
    script = ''
      echo "Unlocking /mnt with keyfile"
      ${pkgs.fscryptctl}/bin/fscryptctl add_key /mnt < /root/key
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  systemd.oomd.enable = false; # fails to start

  ptsd.tailscale = {
    enable = true;
    cert.enable = true;
    # httpServices = [ "paperless" ];
    links = [ "home-assistant" ];
  };

  services.syncthing = let universe = import ../../2configs/universe.nix; in
    {
      enable = true;
      dataDir = "/nix/persistent/var/lib/syncthing";
      openDefaultPorts = true;
      devices = lib.mapAttrs (_: hostcfg: hostcfg.syncthing) (lib.filterAttrs (_: lib.hasAttr "syncthing") universe.hosts);

      folders = {
        "/mnt/syncthing/enno/LuNo" = { label = "enno/LuNo"; id = "3ull9-9deg4"; devices = [ "mb3" "mb4" ]; };
        "/mnt/syncthing/enno/Scans" = { label = "enno/Scans"; id = "ezjwj-xgnhe"; devices = [ "mb4" "iph3" "htz2" ]; };
        "/mnt/syncthing/enno/iOS" = { label = "enno/iOS"; id = "qm9ln-btyqu"; devices = [ "iph3" "mb4" ]; };
        "/mnt/syncthing/luisa/Scans" = { label = "luisa/Scans"; id = "dnryo-kz7io"; devices = [ "mb4" "mb3" "htz2" ]; };
        "/mnt/syncthing/fraam-gdrive-backup" = { label = "fraam-gdrive-backup"; id = "fraam-gdrive-backup"; devices = [ "mb4" ]; };
        "/mnt/syncthing/icloudpd" = { label = "icloudpd"; id = "myfag-uvj2s"; devices = [ "mb4" "nas1" ]; };
        # "/mnt/syncthing/paperless" = { label = "paperless"; id = "pu5le-lk2og"; devices = [ "mb4" ]; type = "receiveonly"; };
        "/mnt/syncthing/rpi4-dl" = { label = "rpi4-dl"; id = "q5frb-pk9qx"; devices = [ "mb4" ]; };
      };
    };

  services.samba = {
    enable = true;
    enableNmbd = false;
    enableWinbindd = false;
    extraConfig = ''
      hosts allow = 192.168.178.0/24
      hosts deny = 0.0.0.0/0
      load printers = no
      local master = no
      max smbd processes = 5
      valid users = syncthing
    '';

    shares =
      let
        defaults = {
          "force group" = "syncthing";
          "force user" = "syncthing";
          "guest ok" = "no";
          "read only" = "no";
          browseable = "no";
        };
      in
      {
        scans-enno = defaults // { path = "/mnt/syncthing/enno/Scans"; };
        scans-luisa = defaults // { path = "/mnt/syncthing/luisa/Scans"; };
      };
  };

  # networking.firewall.allowedTCPPorts = [ 445 ]; # samba
  networking.firewall.trustedInterfaces = [ "eth0" "wlan0" ];

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 2500000; # for syncthing
  };

  systemd.services.rpi-powersave = {
    description = "Set some tunables to save power";
    wantedBy = [ "multi-user.target" ];
    script = ''
      # recommended by `powertop`
      echo 'auto' > '/sys/bus/pci/devices/0000:00:00.0/power/control';
      echo 'auto' > '/sys/bus/pci/devices/0000:01:00.0/power/control';
      echo 'auto' > '/sys/block/sda/device/power/control' || true;
    '';
  };

  # services.paperless = {
  #   enable = true;
  #   dataDir = "/mnt/syncthing/paperless";
  #   user = "syncthing";
  # };

  # # disable autostart
  # systemd.services.paperless-scheduler.wantedBy = lib.mkForce [ ];
  # systemd.services.paperless-consumer.wantedBy = lib.mkForce [ ];
  # systemd.services.paperless-web.wantedBy = lib.mkForce [ ];

  # systemd.services.paperless-scheduler.serviceConfig.BindPaths = [ "/nix/persistent/var/lib/syncthing" ];
  # systemd.services.paperless-consumer.serviceConfig.BindPaths = [ "/nix/persistent/var/lib/syncthing" ];
  # systemd.services.paperless-web.serviceConfig.BindPaths = [ "/nix/persistent/var/lib/syncthing" ];

  # services.unbound =
  #   let
  #     blocklist = pkgs.runCommand "unbound-blocklist" { } ''
  #       cat ${hosts}/hosts | ${pkgs.gnugrep}/bin/grep '^0\.0\.0\.0' | \
  #         ${pkgs.gawk}/bin/awk '{print "local-zone: \""$2"\" always_null"}' \
  #         > $out
  #     '';
  #   in
  #   {
  #     enable = true;
  #     resolveLocalQueries = false;
  #     settings = {
  #       server = {
  #         include = toString blocklist;
  #         interface = [ "eth0" ];
  #         access-control = [
  #           "0.0.0.0/0 allow"
  #           "::/0 allow"
  #         ];
  #       };
  #       forward-zone = [{
  #         name = "fritz.box.";
  #         forward-addr = [ "192.168.178.1" ];
  #       }];
  #     };
  #   };
}
