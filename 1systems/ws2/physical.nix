{ ... }:

{
  imports = [
    ./config.nix
    ../../2configs/hw/ws2021.nix
  ];

  system.stateVersion = "21.05";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd = {
    luks.devices = {
      cryptlvm = {
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNMFN904187J-part2";
      };
    };

    # availableKernelModules = [ "iwlmvm" "mac80211" "iwlwifi" "cfg80211" "af_packet" ];

    # extraUtilsCommands =
    #   ''
    #     copy_bin_and_libs ${pkgs.wpa_supplicant}/bin/wpa_cli
    #     copy_bin_and_libs ${pkgs.wpa_supplicant}/bin/wpa_supplicant
    #   '';

    # preLVMCommands = lib.mkBefore (
    #   let
    #     udhcpcScript = pkgs.writeScript "udhcp-script"
    #       ''
    #         #! /bin/sh
    #         if [ "$1" = bound ]; then
    #           ip address add "$ip/$mask" dev "$interface"
    #           if [ -n "$mtu" ]; then
    #             ip link set mtu "$mtu" dev "$interface"
    #           fi
    #           if [ -n "$staticroutes" ]; then
    #             echo "$staticroutes" \
    #               | sed -r "s@(\S+) (\S+)@ ip route add \"\1\" via \"\2\" dev \"$interface\" ; @g" \
    #               | sed -r "s@ via \"0\.0\.0\.0\"@@g" \
    #               | /bin/sh
    #           fi
    #           if [ -n "$router" ]; then
    #             ip route add "$router" dev "$interface" # just in case if "$router" is not within "$ip/$mask" (e.g. Hetzner Cloud)
    #             ip route add default via "$router" dev "$interface"
    #           fi
    #           if [ -n "$dns" ]; then
    #             rm -f /etc/resolv.conf
    #             for server in $dns; do
    #               echo "nameserver $server" >> /etc/resolv.conf
    #             done
    #           fi
    #         fi
    #       '';
    #     wpaCfg = pkgs.writeText "wpa_supplicant.conf" ''
    #       network={
    #         ssid="XXX"
    #         psk="XXX"
    #       }
    #     '';
    #   in
    #   ''
    #     echo "******************* START WIFI *********************"

    #     echo "bringing up network interface wlan0..."
    #     ip link set wlan0 up

    #     echo "associating with AP..."
    #     wpa_supplicant -i wlan0 -c ${wpaCfg}

    #     echo "waiting 10 secs"
    #     sleep 10

    #     echo "acquiring IP address via DHCP on wlan0..."
    #     udhcpc --quit --now -i wlan0 -O staticroutes --script ${udhcpcScript}

    #     echo "******************** END WIFI **********************"
    #   ''
    # );

    # postMountCommands = ''
    #   ip address flush wlan0
    #   wpa_cli terminate -i wlan0
    #   ip link set wlan0 down
    # '';
  };

  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "size=200M" "mode=1755" ];
  };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNMFN904187J-part1";
      fsType = "vfat";
    };

  fileSystems."/home" =
    {
      device = "/dev/sysVG/home";
      fsType = "ext4";
    };

  fileSystems."/nix" =
    {
      device = "/dev/sysVG/nix";
      fsType = "ext4";
    };

  fileSystems."/persist" =
    {
      device = "/dev/sysVG/persist";
      fsType = "ext4";
    };

  fileSystems."/var/src" = {
    device = "/dev/sysVG/var-src";
    fsType = "ext4";
    neededForBoot = true; # mount early for passwd provisioning
  };

  boot.kernelParams = [
    "mitigations=off" # make linux fast again
    "systemd.machine_id=78a79fa3b73e4177a65efe6e9be87e68"
  ];
}
