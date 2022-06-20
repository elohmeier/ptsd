# Keep in mind this config is also used for NixOS containers.

{ config, lib, pkgs, ... }:
with lib;
let
  universe = import ./universe.nix;
in
{
  imports = [
    ./users/root.nix
  ];

  environment.systemPackages = with pkgs;[ foot.terminfo ];

  users.mutableUsers = false;

  nix = {
    binaryCaches = [
      "https://fraam.cachix.org"
      # "https://nerdworks.cachix.org"
      # "http://${universe.hosts.ws1.nets.bs53lan.ip4.addr}:5000"
    ];
    binaryCachePublicKeys = [
      "fraam.cachix.org-1:jli8HeFa594XmjkCbP7ZgDPaWI8kvdXloTJIIfaxJLw="
      # "nerdworks.cachix.org-1:mt3i8px0W2IFrZ+vs/xu3mawh+XJZFTlZ+eaxMpVr+A="
      # "ws1.host.nerdworks.de-1:XFlt+Bmung8wck0dcTLmhJy4cuEc82zssAK1DBeEF5w="
    ];
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot.initrd.network.ssh.authorizedKeys =
    let
      sshPubKeys = import ./users/ssh-pubkeys.nix;
    in
    sshPubKeys.authorizedKeys_enno;

  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" ];
  };

  programs.command-not-found.enable = false;

  time.timeZone = "Europe/Berlin";

  services.openssh = {
    enable = true;
    permitRootLogin = mkDefault "prohibit-password";
    passwordAuthentication = mkDefault false;
    kbdInteractiveAuthentication = false;

    # sshtunnel compat
    extraConfig = ''
      PubkeyAcceptedKeyTypes=+ssh-rsa
    '';

    knownHosts =
      mapAttrs
        (
          hostname: hostcfg: {
            hostNames =
              [ hostname (if hasAttr "domain" hostcfg then "${hostname}.${hostcfg.domain}" else "${hostname}.host.nerdworks.de") "${hostname}.pug-coho.ts.net" ]
              ++ (mapAttrsToList (_: netcfg: netcfg.ip4.addr) (filterAttrs (netname: netcfg: (netname == "nwvpn" || netname == "bs53lan") && hasAttrByPath [ "ip4" "addr" ] netcfg) hostcfg.nets))
              # below additions not always useful, e.g. gitlab-container on htz3 with different ssh-key used only on same public ip - so we only use the above nwvpn ip for now and below manual definitions
              # ++ (mapAttrsToList (_: netcfg: netcfg.ip4.addr) (filterAttrs (_: netcfg: hasAttrByPath [ "ip4" "addr" ] netcfg) hostcfg.nets))
              # ++ (mapAttrsToList (_: netcfg: netcfg.ip6.addr) (filterAttrs (_: netcfg: hasAttrByPath [ "ip6" "addr" ] netcfg) hostcfg.nets))
              ++ (flatten (mapAttrsToList (_: netcfg: netcfg.aliases) (filterAttrs (_: netcfg: hasAttr "aliases" netcfg) hostcfg.nets)))
            ;
            publicKey = hostcfg.ssh.pubkey;
          }
        )
        (filterAttrs (_: hostcfg: hasAttrByPath [ "ssh" "pubkey" ] hostcfg) universe.hosts)
      // {
        "github" =
          {
            hostNames = [ "github.com" ];
            publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";
          };
        "nwgit" = {
          hostNames = [ universe.hosts.htz1.nets.www.ip4.addr universe.hosts.htz1.nets.www.ip6.addr ] ++ universe.hosts.htz1.nets.www.aliases;
          publicKey = universe.hosts.htz1.ssh.pubkey;
        };
        "fraamgit" = {
          hostNames = [ universe.hosts.htz3.nets.www.ip4.addr universe.hosts.htz3.nets.www.ip6.addr "git.fraam.de" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKqi/Ley5IzAX4+x7446j/mEKFekN4pdfYSxesxO48LP";
        };

        # https://docs.hetzner.com/de/robot/storage-box/access/access-ssh-rsync-borg/#ssh-host-keys
        "hetzner-storage-box-ed25519" = {
          hostNames = [ "u267169.your-storagebox.de" "[u267169.your-storagebox.de]:23" ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
        };
        "hetzner-storage-box-rsa" = {
          hostNames = [ "u267169.your-storagebox.de" "[u267169.your-storagebox.de]:23" ];
          publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5EB5p/5Hp3hGW1oHok+PIOH9Pbn7cnUiGmUEBrCVjnAw+HrKyN8bYVV0dIGllswYXwkG/+bgiBlE6IVIBAq+JwVWu1Sss3KarHY3OvFJUXZoZyRRg/Gc/+LRCE7lyKpwWQ70dbelGRyyJFH36eNv6ySXoUYtGkwlU5IVaHPApOxe4LHPZa/qhSRbPo2hwoh0orCtgejRebNtW5nlx00DNFgsvn8Svz2cIYLxsPVzKgUxs8Zxsxgn+Q/UvR7uq4AbAhyBMLxv7DjJ1pc7PJocuTno2Rw9uMZi1gkjbnmiOh6TTXIEWbnroyIhwc8555uto9melEUmWNQ+C+PwAK+MPw==";
        };
      };
  };

  ptsd.wireguard.networks = {
    dlrgvpn = {
      publicKey = "BoZpusHOB9dNMFvnpwV2QitB0ejJEDAhEUPv+uI9iFo=";
      # publicKey = "DXmzQWZjP7EeW9P6lysxpEVi3Cq6zfqAHg2od3bCZ20="; # avm labor vpn
      client = {
        #endpoint = "hvrhukr39ruezms4.myfritz.net:55557"; # old 7490
        endpoint = "letvjkxepuccuto1.myfritz.net:55557"; # new 7590
        # endpoint = "letvjkxepuccuto1.myfritz.net:51551"; # avm labor vpn
        reresolveDns = true;
        allowedIPs = [ "191.18.21.0/24" ];
      };
      server.listenPort = 55557; # on rpi2
    };

    fraam_buero_vpn = {
      publicKey = "edW3MrRctb1Yed5fHRiSPcDMdvCU/zZpLG1CBqiFY0k=";
      client = {
        endpoint = "94.134.201.30:55555";
        allowedIPs = [ "191.18.23.0/24" ];
      };
    };

    nwvpn = {
      publicKey = "UeAoj/VLCmoWLGjAkFRXYLYeac/tLM2itmkq4GKz0zg=";
      client = {
        endpoint = "159.69.186.234:55555";
        allowedIPs = [ "191.18.19.0/24" ];
      };
      server.listenPort = 55555;
    };
  };

  security.polkit.extraConfig = ''
    /* Allow admins to login into machines or manage systemd units without password */
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.machine1.login" ||
           action.id == "org.freedesktop.systemd1.manage-units") &&
          subject.isInGroup("wheel"))
      {
        return polkit.Result.YES;
      }
    });
  '';

  systemd.coredump.extraConfig = "Storage=none";

  programs.bash.interactiveShellInit = ''
    booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules})"
    built="$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"

    if [ "$booted" != "$built" ]; then
      echo "please reboot"
    fi
  '';

  boot.loader.systemd-boot.editor = lib.mkDefault false;

  security.sudo.execWheelOnly = true;

  # not working on htz1? TODO: check
  # documentation.man = {
  #   man-db.enable = false;
  #   mandoc.enable = true;
  # };
}
