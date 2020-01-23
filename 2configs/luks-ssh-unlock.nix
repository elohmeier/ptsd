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
