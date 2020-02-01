{ config, lib, pkgs, ... }:
let
  unlock = pkgs.writeScriptBin "unlock" ''
    #!/bin/sh
    echo -n "Please enter passphrase: "
    IFS= read -rs passphrase
    echo -n "$passphrase" > /crypt-ramfs/passphrase
  '';
in
{
  # You should configure `boot.initrd.luks.devices` for this to function, e.g.:
  # boot.initrd.luks.devices = [
  #   {
  #     name = "myvg";
  #     device = "/dev/sda2";
  #     preLVM = true;
  #   }
  # ];

  # use network cfg like this:
  # networking.useDHCP = false;
  # networking.interfaces."eno1".useDHCP = true;
  # (tested with networkd)

  # find your network driver module name using
  # `ls -l /sys/class/net/<devname>/device/driver`
  # and add it to boot.initrd.availableKernelModules

  # rename your primary ethernet device to "eth0", because
  # this is probably the name used inside the initrd.
  # e.g.
  #services.udev.extraRules = ''
  #  SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="a8:a1:59:04:c6:f8", NAME="eth0"
  #'';

  boot.initrd = {
    extraUtilsCommands = ''
      copy_bin_and_libs ${unlock}/bin/unlock
    '';
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        hostECDSAKey = (toString <secrets>) + "/initrd-ssh-key";
      };
      postCommands = ''
        echo "unlock" >> /root/.profile
      '';
    };
  };
}
