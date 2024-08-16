{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  virshNatIpPrefix = "192.168.197"; # "XXX.XXX.XXX" without last block
  virshNatIf = "virsh-nat";
  nonAarch64 = pkgs.stdenv.hostPlatform.system != "aarch64-linux";
in
{
  boot.binfmt.emulatedSystems = mkIf nonAarch64 [ "aarch64-linux" ];

  # required for libvirt
  security.polkit.enable = true;

  virtualisation = mkIf nonAarch64 {
    docker = {
      enable = mkDefault true;
      enableOnBoot = false; # will be socket-activated
    };
    libvirtd = {
      enable = mkDefault true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
      };
    };
    #    virtualbox.host =  {
    #      enable = true;
    #      enableExtensionPack = true;
    #    };
  };

  services.samba = mkIf nonAarch64 {
    enable = mkDefault true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${config.networking.hostName}
      netbios name = ${config.networking.hostName}
    '';
    # hosts allow = ${virshNatIpPrefix}.0/24 # virshNat network
    # hosts deny = 0.0.0.0/0

    shares = {
      home = {
        path = "/home/enno";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
      };
    };
  };

  environment.systemPackages =
    with pkgs;
    mkIf nonAarch64 [
      samba
      # looking-glass-client
      # scream
      virt-viewer
      virtmanager
    ];

  networking = mkIf nonAarch64 {
    useNetworkd = true;

    firewall.interfaces = {
      "${virshNatIf}" = {
        allowedTCPPorts = [
          53
          631
          445
          139
        ];
        allowedUDPPorts = [
          53
          67
          68
          546
          547
          137
          138
          4011
        ];
      };
    };

    firewall.trustedInterfaces = [ virshNatIf ];

    nat = {
      enable = true;
      internalInterfaces = [ virshNatIf ];
    };
  };

  systemd.network = mkIf nonAarch64 {
    netdevs = {
      "40-${virshNatIf}" = {
        netdevConfig = {
          Name = virshNatIf;
          Kind = "bridge";
        };
      };
    };
    networks = {
      "40-${virshNatIf}" = {
        matchConfig.Name = virshNatIf;
        networkConfig = {
          ConfigureWithoutCarrier = true;
          DHCPServer = true;
          Address = "${virshNatIpPrefix}.1/24";
        };
      };
    };
  };
}
