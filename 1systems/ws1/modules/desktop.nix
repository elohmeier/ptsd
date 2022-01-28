{ config, lib, pkgs, ... }: {

  ptsd.desktop = {
    enable = true;
    waybar.co2 = true;
    # nvidia.enable = true; # todo: replace writeNu in desktop module
    autolock.enable = false;
    baresip = {
      enable = true;
    };
    fontSize = 18.0;
    waybar.primaryOutput = "Dell Inc. DELL P2415Q D8VXF96K09HB";
  };

  home-manager.users.mainUser = { pkgs, ... }: {
    wayland.windowManager.sway.config.output = {
      "Goldstar Company Ltd LG UltraFine 701NTAB7S144" = {
        pos = "0 0";
        mode = "4096x2304@59.999Hz";
        scale = "1";
        bg = "/home/enno/Pocket/JI2A5332.JPG fill";
      };
      "Dell Inc. DELL P2415Q D8VXF96K09HB" = {
        #pos = "0 2304";
        pos = "256 2304";
        mode = "3840x2160@59.997Hz";
        scale = "1";
        bg = "/home/enno/Downloads/JI2A4943.JPG fill";
      };
      "Dell Inc. DELL P2415Q D8VXF64G0LGL" = {
        # pos = "3840 2304";
        pos = "4096 360";
        mode = "3840x2160@59.997Hz";
        scale = "1";
        transform = "270";
        bg = "/home/enno/Downloads/JI2A5337_90.JPG fill";
      };
    };
  };

}
