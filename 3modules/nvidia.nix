{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.nvidia;
  nvidia_x11 = config.boot.kernelPackages.nvidia_x11;
in
{
  options = {
    ptsd.nvidia = {
      headless.enable = mkOption {
        type = types.bool;
        description = "configures nvidia proprietary drivers and the nvidia persistence daemon to enable CUDA workloads (e.g. hashcat) w/o using the GPU for a graphical desktop environment";
        default = false;
      };
      vfio.enable = mkOption {
        type = types.bool;
        description = "blocks nvidia/nouveau drivers to keep the GPU clear for vfio pci-passthrough in QEMU/KVM";
        default = false;
      };
    };
  };

  config = mkMerge [
    {
      assertions = [{
        assertion = !(cfg.headless.enable && cfg.vfio.enable);
        message = "ptsd.nvidia.headless.enable and -.vfio.enable are mutually exclusive";
      }];
    }

    (mkIf cfg.headless.enable {
      boot = {
        blacklistedKernelModules = [
          "nouveau"
        ];

        extraModulePackages = [
          nvidia_x11.bin
        ];

        kernelModules = [
          "nvidia-uvm"
        ];
      };

      environment.systemPackages = with pkgs; [
        nvidia_x11.bin
        nvidia_x11.settings
        nvidia_x11.persistenced
        nvtop
        cudatoolkit
      ];

      hardware = {
        opengl = {
          enable = true;
          driSupport = true;
          driSupport32Bit = true;
          extraPackages = [ nvidia_x11.out ];
          extraPackages32 = [ nvidia_x11.lib32 ];
        };
      };

      systemd.services.nvidia-persistenced =
        {
          description = "NVIDIA Persistence Daemon";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "forking";
            Restart = "always";
            PIDFile = "/var/run/nvidia-persistenced/nvidia-persistenced.pid";
            ExecStart = "${nvidia_x11.persistenced}/bin/nvidia-persistenced --verbose";
            ExecStopPost = "${pkgs.coreutils}/bin/rm -rf /var/run/nvidia-persistenced";
          };
        };

      services.udev.extraRules =
        ''
          # Create /dev/nvidia-uvm when the nvidia-uvm module is loaded.
          KERNEL=="nvidia", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidiactl c $$(grep nvidia-frontend /proc/devices | cut -d \  -f 1) 255'"
          KERNEL=="nvidia_modeset", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia-modeset c $$(grep nvidia-frontend /proc/devices | cut -d \  -f 1) 254'"
          KERNEL=="card*", SUBSYSTEM=="drm", DRIVERS=="nvidia", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia%n c $$(grep nvidia-frontend /proc/devices | cut -d \  -f 1) %n'"
          KERNEL=="nvidia_uvm", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia-uvm c $$(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 0'"
          KERNEL=="nvidia_uvm", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia-uvm-tools c $$(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 0'"
        '';
    })

    (mkIf cfg.vfio.enable {
      boot = {
        blacklistedKernelModules = [
          "nouveau"
          "nvidia"
          "nvidia_drm"
          "nvidia_uvm"
          "nvidia_modeset"
          "i2c_nvidia_gpu"
        ];
        kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
        extraModprobeConfig = ''
          options kvm ignore_msrs=1
        '';
      };
    })
  ];
}
