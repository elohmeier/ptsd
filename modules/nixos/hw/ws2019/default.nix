{ lib, pkgs, ... }:

{
  imports = [
    ./kernel.nix
  ];

  console.font = "${pkgs.spleen}/share/consolefonts/spleen-12x24.psfu";
  console.keyMap = "de-latin1";

  environment.systemPackages = with pkgs; [
    efibootmgr
    efitools
    tpm2-tools
    vulkan-tools
  ];

  hardware = {
    cpu.amd.updateMicrocode = true;
    firmware = with pkgs; [
      firmwareLinuxNonfree
      broadcom-bt-firmware # for the plugable USB stick
    ];
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
        rocm-opencl-icd
        rocm-runtime
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        driversi686Linux.amdvlk
      ];
    };
  };

  nix.maxJobs = lib.mkDefault 24;

  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  services.xserver = {
    videoDrivers = [ "amdgpu" ];
    xrandrHeads = [
      {
        output = "DisplayPort-0";
        monitorConfig = ''Option "Above" "DisplayPort-1"'';
      }
      {
        output = "DisplayPort-1";
        primary = true; # fixes missing tray in i3bar
      }
      {
        output = "DisplayPort-2";
      }
    ];
  };

  ptsd.nvidia.headless.enable = lib.mkDefault false;
  ptsd.nvidia.vfio.enable = lib.mkDefault true;
}
