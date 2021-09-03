{ pkgs, ... }:

{
  # environment.systemPackages = with pkgs;[ screen minicom socat python3 vim ];

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

  # see https://www.carberry.it/wiki/carberry/sw_comm
  systemd.services.carberry-serialmux =
    let serialmux = pkgs.writers.writePython3 "serialmux"
      {
        libraries = [ pkgs.python3Packages.pyserial ];
        flakeIgnore = [ "E501" ]; # line length (black)
      } ./serialmux.py;

    in
    {
      description = "Carberry TCP to serial proxy";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${serialmux} --device /dev/ttyS0 --listen 127.0.0.1 --port 5000";
      };
    };
}
