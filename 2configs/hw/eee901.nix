{ config, lib, pkgs, ... }:

let

  # just take the needed firmware files to reduce size
  rt2860-firmware = pkgs.runCommand "rt2860-firmware" { } ''          
          mkdir -p $out/lib/firmware
          cp ${pkgs.firmwareLinuxNonfree}/lib/firmware/rt2860.bin $out/lib/firmware/
        '';

in
{
  boot.initrd = {
    availableKernelModules = [ "uhci_hcd" "ehci_pci" "ata_piix" "usb_storage" "sd_mod" ];
    kernelModules = [ "i915" ];
  };

  nix.maxJobs = lib.mkDefault 2;

  hardware.cpu.intel.updateMicrocode = true;

  # requires wifi firmware rt2860.bin
  hardware.firmware = with pkgs; [
    # firmwareLinuxNonfree
    rt2860-firmware
  ];

  console.keyMap = "de-latin1";
  console.font = "${pkgs.spleen}/share/consolefonts/spleen-6x12.psfu";
}
