# Keep in mind this config is also used for NixOS containers.

{ lib, pkgs, ... }:
with lib;
let
  universe = import ../common/universe.nix;
in
{
  imports = [
    ./users/root.nix
  ];

  users.mutableUsers = false;

  nix = {
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

  programs.command-not-found.enable = false;

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
              ++ (mapAttrsToList (_: netcfg: netcfg.ip4.addr) (filterAttrs (netname: netcfg: (netname == "nwvpn" || netname == "bs53lan" || netname == "tailscale") && hasAttrByPath [ "ip4" "addr" ] netcfg) hostcfg.nets))
              # below additions not always useful, e.g. gitlab-container on htz3 with different ssh-key used only on same public ip - so we only use the above nwvpn ip for now and below manual definitions
              # ++ (mapAttrsToList (_: netcfg: netcfg.ip4.addr) (filterAttrs (_: netcfg: hasAttrByPath [ "ip4" "addr" ] netcfg) hostcfg.nets))
              # ++ (mapAttrsToList (_: netcfg: netcfg.ip6.addr) (filterAttrs (_: netcfg: hasAttrByPath [ "ip6" "addr" ] netcfg) hostcfg.nets))
              ++ (flatten (mapAttrsToList (_: netcfg: netcfg.aliases) (filterAttrs (_: hasAttr "aliases") hostcfg.nets)))
            ;
            publicKey = hostcfg.ssh.pubkey;
          }
        )
        (filterAttrs (_: hasAttrByPath [ "ssh" "pubkey" ]) universe.hosts)
      // {
        "github" =
          {
            hostNames = [ "github.com" ];
            publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
          };
        "nwgit" = {
          hostNames = [ universe.hosts.htz1.nets.www.ip4.addr universe.hosts.htz1.nets.www.ip6.addr ] ++ universe.hosts.htz1.nets.www.aliases;
          publicKey = universe.hosts.htz1.ssh.pubkey;
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
        allowedIPs = [ "191.18.21.0/24" ];
      };
      reresolveDns = true;
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

  security.acme = {
    acceptTerms = true;
    defaults.email = lib.mkDefault "elo-lenc@nerdworks.de";
  };

  programs.fish.interactiveShellInit = ''
    set -U fish_greeting
    source ${../../scripts/iterm2-integration.fish}
  '';
}
