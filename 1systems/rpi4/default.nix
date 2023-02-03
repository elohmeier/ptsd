{ config, lib, pkgs, hosts, ... }: {

  imports = [
    ../../2configs
    ../../2configs/borgbackup.nix
    ../../2configs/fish.nix
    ../../2configs/hw/rpi3b_4.nix
    ../../2configs/nix-persistent.nix
    ../../2configs/prometheus-node.nix

    ./disks.nix
    ./icloudpd.nix
    ./fluent-bit.nix
    ./fraam-gdrive-backup.nix
    ./home-assistant.nix
    ./photoprism.nix
  ];

  services.eternal-terminal.enable = true;

  boot.loader.raspberryPi = {
    enable = true;
    uboot.enable = true;
    version = 4;
  };
  users.users.root.openssh.authorizedKeys.keys =
    let sshPubKeys = import ../../2configs/users/ssh-pubkeys.nix; in sshPubKeys.authorizedKeys_enno;

  services.openssh.enable = true;

  boot.loader.generic-extlinux-compatible.enable = false;

  system.stateVersion = "22.11";

  services.borgbackup.jobs.hetzner = {
    paths = [
      "/nix/persistent"
      "/nix/secrets"
      "/var/backup"
      "/var/lib/hass"
      "/var/lib/photoprism"
      "/var/lib/syncthing"
    ];
    exclude = [
      "/var/lib/syncthing/rpi4-dl"
    ];
  };

  services.mysqlBackup = {
    enable = true;
    databases = [ "photoprism" ];
  };

  #services.getty.autologinUser = "enno";
  #security.sudo.wheelNeedsPassword = false;
  #nix.settings.trusted-users = [ "root" "@wheel" ];
  networking.hostName = "rpi4";
  environment.systemPackages = with pkgs;[
    btop
    cryptsetup
    gptfdisk
    iperf2
    ncdu
    powertop
    ptsd-nnn
    tmux
  ];

  services.borgbackup.repos =
    let
      cfg = hostname: {
        authorizedKeysAppendOnly = [ (import ../../2configs/universe.nix).hosts."${hostname}".borg.pubkey ];
        path = "/srv/borgbackup/${hostname}";
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
      bae0thiu = cfg "bae0thiu";
    };

  # pin uids (not persisted)
  users.users.borg-apu2.uid = 901;
  users.users.borg-htz1.uid = 902;
  users.users.borg-htz2.uid = 903;
  users.users.borg-htz3.uid = 904;
  users.users.borg-mb3.uid = 905;
  users.users.borg-mb4.uid = 906;

  systemd.oomd.enable = false; # fails to start

  ptsd.tailscale = {
    enable = true;
    cert.enable = true;
    httpServices = [ "photoprism" ];
    links = [ "home-assistant" ];
  };

  services.syncthing = let universe = import ../../2configs/universe.nix; in
    {
      enable = true;
      dataDir = "/var/lib/syncthing";
      openDefaultPorts = true;
      devices = lib.mapAttrs (_: hostcfg: hostcfg.syncthing) (lib.filterAttrs (_: lib.hasAttr "syncthing") universe.hosts);

      folders = {
        "/var/lib/syncthing/enno/LuNo" = { label = "enno/LuNo"; id = "3ull9-9deg4"; devices = [ "mb3" "mb4" ]; };
        "/var/lib/syncthing/enno/Scans" = { label = "enno/Scans"; id = "ezjwj-xgnhe"; devices = [ "mb4" "iph3" "ipd1" "htz2" ]; };
        "/var/lib/syncthing/enno/iOS" = { label = "enno/iOS"; id = "qm9ln-btyqu"; devices = [ "iph3" "ipd1" "mb4" ]; };
        "/var/lib/syncthing/luisa/Scans" = { label = "luisa/Scans"; id = "dnryo-kz7io"; devices = [ "mb4" "mb3" "htz2" ]; };
        "/var/lib/syncthing/fraam-gdrive-backup" = { label = "fraam-gdrive-backup"; id = "fraam-gdrive-backup"; devices = [ "mb4" ]; };
        # "/var/lib/syncthing/paperless" = { label = "paperless"; id = "pu5le-lk2og"; devices = [ "mb4" ]; type = "receiveonly"; };
        "/var/lib/syncthing/rpi4-dl" = { label = "rpi4-dl"; id = "q5frb-pk9qx"; devices = [ "mb4" "ws2" ]; };
        "/var/lib/syncthing/photos" = { label = "photos"; id = "9usxu-er25n"; devices = [ "mb4" ]; };
      };
    };

  systemd.services.syncthing.serviceConfig = {
    CPUSchedulingPolicy = "idle";
    IOSchedulingClass = "idle";
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
        scans-enno = defaults // { path = "/var/lib/syncthing/enno/Scans"; };
        scans-luisa = defaults // { path = "/var/lib/syncthing/luisa/Scans"; };
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

      # disable wifi (causing reboots?)
      ${pkgs.util-linux}/bin/rfkill block wlan;
    '';
  };

  networking.wireless.iwd.enable = false;

  ## services.paperless = {
  ##   enable = true;
  ##   dataDir = "/var/lib/syncthing/paperless";
  ##   user = "syncthing";
  ## };

  ## # disable autostart
  ## systemd.services.paperless-scheduler.wantedBy = lib.mkForce [ ];
  ## systemd.services.paperless-consumer.wantedBy = lib.mkForce [ ];
  ## systemd.services.paperless-web.wantedBy = lib.mkForce [ ];

  ## systemd.services.paperless-scheduler.serviceConfig.BindPaths = [ "/nix/persistent/var/lib/syncthing" ];
  ## systemd.services.paperless-consumer.serviceConfig.BindPaths = [ "/nix/persistent/var/lib/syncthing" ];
  ## systemd.services.paperless-web.serviceConfig.BindPaths = [ "/nix/persistent/var/lib/syncthing" ];

  ## services.unbound =
  ##   let
  ##     blocklist = pkgs.runCommand "unbound-blocklist" { } ''
  ##       cat ${hosts}/hosts | ${pkgs.gnugrep}/bin/grep '^0\.0\.0\.0' | \
  ##         ${pkgs.gawk}/bin/awk '{print "local-zone: \""$2"\" always_null"}' \
  ##         > $out
  ##     '';
  ##   in
  ##   {
  ##     enable = true;
  ##     resolveLocalQueries = false;
  ##     settings = {
  ##       server = {
  ##         include = toString blocklist;
  ##         interface = [ "eth0" ];
  ##         access-control = [
  ##           "0.0.0.0/0 allow"
  ##           "::/0 allow"
  ##         ];
  ##       };
  ##       forward-zone = [{
  ##         name = "fritz.box.";
  ##         forward-addr = [ "192.168.178.1" ];
  ##       }];
  ##     };
  ##   };

  documentation = {
    enable = false;
    man.enable = false;
    info.enable = false;
    doc.enable = false;
    dev.enable = false;
  };

  ptsd.fastd = {
    enable = true;
    networks.ffhb = {
      mtu = 1280;
      peers = [
        {
          hostname = "vpn07.bremen.freifunk.net";
          port = 50000;
          publickey = "68220e494e7a415d5dd97b5aa7a0d82088ed971f468ff16bcfd08fe0d4d6449f";
        }
        {
          hostname = "vpn08.bremen.freifunk.net";
          port = 50000;
          publickey = "8a2cee2fa56fb32e356ad08d6a2578978d45b2f6263a3e252b3dbde1fde27604";
        }
      ];
    };
  };

  containers.ff = {
    autoStart = false;
    ephemeral = true;
    macvlans = [ "bat-ffhb" ];
    bindMounts = {
      "/home/gordon/rpi4-dl" = { hostPath = "/var/lib/syncthing/rpi4-dl"; isReadOnly = false; };
    };
    config = { pkgs, ... }: {
      system.stateVersion = "22.11";

      environment.systemPackages = with pkgs; [ rtorrent ];

      networking = {
        useDHCP = false;
        interfaces.mv-bat-ffhb.useDHCP = true;
      };

      # Manually configure nameserver. Using resolved inside the container seems to fail
      # currently
      environment.etc."resolv.conf".text = "nameserver 8.8.8.8";

      services.getty.autologinUser = "gordon";

      # copy syncthing uid/gid
      users.groups.gordon.gid = 237;
      users.users.gordon = {
        createHome = true;
        group = "gordon";
        home = "/home/gordon";
        homeMode = "700";
        isSystemUser = true;
        uid = 237;
        useDefaultShell = true;
      };
    };
  };
}
