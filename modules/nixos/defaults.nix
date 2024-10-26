# Keep in mind this config is also used for NixOS containers.

{ lib, ... }:
with lib;
let
  universe = import ../common/universe.nix;
in
{
  imports = [ ./users/root.nix ];

  users.mutableUsers = false;

  nix = {
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
    enable = lib.mkDefault true;

    settings = {
      PermitRootLogin = mkDefault "prohibit-password";
      PasswordAuthentication = mkDefault false;
      KbdInteractiveAuthentication = false;
    };

    # sshtunnel compat
    extraConfig = ''
      PubkeyAcceptedKeyTypes=+ssh-rsa
    '';

    knownHosts =
      mapAttrs
        (hostname: hostcfg: {
          hostNames =
            [
              hostname
              (
                if hasAttr "domain" hostcfg then
                  "${hostname}.${hostcfg.domain}"
                else
                  "${hostname}.host.nerdworks.de"
              )
              "${hostname}.pug-coho.ts.net"
            ]
            ++ (mapAttrsToList (_: netcfg: netcfg.ip4.addr) (
              filterAttrs (
                netname: netcfg:
                (netname == "nwvpn" || netname == "bs53lan" || netname == "tailscale")
                && hasAttrByPath [
                  "ip4"
                  "addr"
                ] netcfg
              ) hostcfg.nets
            ))
            # below additions not always useful, e.g. gitlab-container on htz3 with different ssh-key used only on same public ip - so we only use the above nwvpn ip for now and below manual definitions
            # ++ (mapAttrsToList (_: netcfg: netcfg.ip4.addr) (filterAttrs (_: netcfg: hasAttrByPath [ "ip4" "addr" ] netcfg) hostcfg.nets))
            # ++ (mapAttrsToList (_: netcfg: netcfg.ip6.addr) (filterAttrs (_: netcfg: hasAttrByPath [ "ip6" "addr" ] netcfg) hostcfg.nets))
            ++ (flatten (
              mapAttrsToList (_: netcfg: netcfg.aliases) (filterAttrs (_: hasAttr "aliases") hostcfg.nets)
            ));
          publicKey = hostcfg.ssh.pubkey;
        })
        (
          filterAttrs (
            _:
            hasAttrByPath [
              "ssh"
              "pubkey"
            ]
          ) universe.hosts
        )
      // {
        "github" = {
          hostNames = [ "github.com" ];
          publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
        };
        "nwgit" = {
          hostNames = [
            universe.hosts.htz1.nets.www.ip4.addr
            universe.hosts.htz1.nets.www.ip6.addr
          ] ++ universe.hosts.htz1.nets.www.aliases;
          publicKey = universe.hosts.htz1.ssh.pubkey;
        };

        # https://docs.hetzner.com/de/robot/storage-box/access/access-ssh-rsync-borg/#ssh-host-keys
        "hetzner-storage-box-ed25519" = {
          hostNames = [
            "u267169.your-storagebox.de"
            "[u267169.your-storagebox.de]:23"
          ];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
        };
        "hetzner-storage-box-rsa" = {
          hostNames = [
            "u267169.your-storagebox.de"
            "[u267169.your-storagebox.de]:23"
          ];
          publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5EB5p/5Hp3hGW1oHok+PIOH9Pbn7cnUiGmUEBrCVjnAw+HrKyN8bYVV0dIGllswYXwkG/+bgiBlE6IVIBAq+JwVWu1Sss3KarHY3OvFJUXZoZyRRg/Gc/+LRCE7lyKpwWQ70dbelGRyyJFH36eNv6ySXoUYtGkwlU5IVaHPApOxe4LHPZa/qhSRbPo2hwoh0orCtgejRebNtW5nlx00DNFgsvn8Svz2cIYLxsPVzKgUxs8Zxsxgn+Q/UvR7uq4AbAhyBMLxv7DjJ1pc7PJocuTno2Rw9uMZi1gkjbnmiOh6TTXIEWbnroyIhwc8555uto9melEUmWNQ+C+PwAK+MPw==";
        };
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
