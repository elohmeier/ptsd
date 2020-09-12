# Keep in mind this config is also used for NixOS containers.
with import <ptsd/lib>;
{ config, pkgs, ... }:
let
  sshPubKeys = import ./ssh-pubkeys.nix;
  authorizedKeys = [
    sshPubKeys.sshPub.ipd1_terminus
    sshPubKeys.sshPub.ipd1_workingcopy
    sshPubKeys.sshPub.iph1_terminus
    sshPubKeys.sshPub.iph1_workingcopy
    sshPubKeys.sshPub.tp1
    sshPubKeys.sshPub.ws1
    sshPubKeys.sshPub.enno_yubi41
    sshPubKeys.sshPub.enno_yubi49
    sshPubKeys.sshPub.drone_exec_runner_ws1
  ];
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    {
      users.users =
        mapAttrs
          (_: h: { hashedPassword = h; })
          (import <secrets/hashedPasswords.nix>);
    }
    {
      users.users = {
        root = {
          openssh.authorizedKeys.keys = authorizedKeys;
        };

        mainUser = {
          name = "enno";
          isNormalUser = true;
          home = "/home/enno";
          createHome = true;
          useDefaultShell = true;
          uid = 1000;
          description = "Enno Richter";
          extraGroups =
            [ "wheel" "networkmanager" "libvirtd" "docker" "syncthing" "video" "dialout" ];
          openssh.authorizedKeys.keys = authorizedKeys;
        };
      };
    }
  ];

  environment = {
    shellAliases = import ./aliases.nix;
    systemPackages = with pkgs; [
      gitMinimal # required for krops
    ];
    variables = {
      NIX_PATH = mkForce "secrets=/var/src/ptsd/null:/var/src";
    };
  };

  users.mutableUsers = false;

  nix = {
    binaryCaches = [
      "https://nerdworks.cachix.org"
      "http://192.168.178.218:5000"
    ];
    binaryCachePublicKeys = [
      "nerdworks.cachix.org-1:mt3i8px0W2IFrZ+vs/xu3mawh+XJZFTlZ+eaxMpVr+A="
      "ws1.host.nerdworks.de-1:XFlt+Bmung8wck0dcTLmhJy4cuEc82zssAK1DBeEF5w="
    ];
  };

  boot.initrd.network.ssh.authorizedKeys = authorizedKeys;

  i18n.defaultLocale = "de_DE.UTF-8";

  time.timeZone = "Europe/Berlin";

  services.openssh = {
    enable = true;
    permitRootLogin = mkDefault "prohibit-password";
    passwordAuthentication = false;
    challengeResponseAuthentication = false;

    knownHosts =
      mapAttrs
        (
          hostname: hostcfg: {
            hostNames =
              [ hostname (if hasAttr "domain" hostcfg then "${hostname}.${hostcfg.domain}" else "${hostname}.host.nerdworks.de") ]
              ++ (mapAttrsToList (_: netcfg: netcfg.ip4.addr) (filterAttrs (_: netcfg: hasAttrByPath [ "ip4" "addr" ] netcfg) hostcfg.nets))
              ++ (mapAttrsToList (_: netcfg: netcfg.ip6.addr) (filterAttrs (_: netcfg: hasAttrByPath [ "ip6" "addr" ] netcfg) hostcfg.nets))
              ++ (flatten (mapAttrsToList (_: netcfg: netcfg.aliases) (filterAttrs (_: netcfg: hasAttr "aliases" netcfg) hostcfg.nets)));
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
      };
  };

  ptsd.wireguard.networks = {
    dlrgvpn = {
      publicKey = "BoZpusHOB9dNMFvnpwV2QitB0ejJEDAhEUPv+uI9iFo=";
      client = {
        #endpoint = "hvrhukr39ruezms4.myfritz.net:55557"; # old 7490
        endpoint = "letvjkxepuccuto1.myfritz.net:55557"; # new 7590
        reresolveDns = true;
        allowedIPs = [ "191.18.21.0/24" ];
      };
      server.listenPort = 55557;
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
}
