{ config, lib, pkgs, ... }:

{

  hardware.printers = {
    ensurePrinters = [
      {
        name = "HL5380DN";
        deviceUri = "socket://192.168.1.2:9100";
        location = "fraam office";
        model = "drv:///sample.drv/generpcl.ppd";
        ppdOptions = {
          PageSize = "A4";
          Resolution = "600dpi";
          InputSlot = "Auto";
          MediaType = "PLAIN";
        };
      }
    ];
  };

}
