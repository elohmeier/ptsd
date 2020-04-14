{ config, lib, pkgs, ... }:

{
  hardware.printers = {
    ensureDefaultPrinter = "MFC7440N";
    ensurePrinters = [
      {
        name = "MFC7440N";
        deviceUri = "socket://192.168.178.33:9100";
        model = "drv:///brlaser.drv/br7360n.ppd";
        ppdOptions = {
          PageSize = "A4";
          Resolution = "600dpi";
          InputSlot = "Auto";
          MediaType = "PLAIN";
          brlaserEconomode = "False";
        };
      }
    ];
  };
}
