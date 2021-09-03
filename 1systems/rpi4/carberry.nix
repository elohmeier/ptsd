{ pkgs, ... }:

{
  environment.systemPackages = with pkgs;[ screen minicom socat ];

  systemd.services.carberry-shutdown = {
    description = "Carberry shutdown daemon";
    documentation = [ "https://www.carberry.it/wiki/carberry/rpi/daemons/shutdown" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      #Export GPIO27 
      echo 27 > /sys/class/gpio/export
      #Turn GPIO27 in input
      echo in > /sys/class/gpio/gpio27/direction
      #Turn on GPIO27 pullup
      echo high > /sys/class/gpio/gpio27/direction
        
      while (true)
      do
          if [ $(</sys/class/gpio/gpio27/value) == 0 ]
          then
              shutdown -h now "System halted by Carberry"
          fi    
          sleep 1
      done
    '';
  };

  systemd.services.carberry-proxy = {
    description = "Carberry TCP to serial proxy";
    wantedBy = [ "multi-user.target" ];

    # see https://www.carberry.it/wiki/carberry/sw_comm
    serviceConfig = {
      # TODO: forward carberry responses to all connected clients, currently only works for single client
      ExecStart = "${pkgs.socat}/bin/socat /dev/ttyS0,b115200,raw,echo=0,crnl tcp-listen:5000,fork,bind=127.0.0.1";
    };
  };
}
