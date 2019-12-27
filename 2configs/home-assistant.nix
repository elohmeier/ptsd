{ config, lib, pkgs, ... }:

{
  services.home-assistant = {
    enable = true;

    package = pkgs.home-assistant.override {
      extraPackages = ps: with ps; [
        ps.influxdb
        ps.paho-mqtt
        (
          ps.buildPythonPackage rec {
            pname = "pyfritzhome";
            version = "0.4.2";
            doCheck = false;
            propagatedBuildInputs = [ ps.requests ];
            src = ps.fetchPypi {
              inherit pname version;
              sha256 = "0ncyv8svw0fhs01ijjkb1gcinb3jpyjvv9xw1bhnf4ri7b27g6ww";
            };
          }
        )
        ps.pyhomematic
        (
          ps.buildPythonPackage rec {
            pname = "PyMetno";
            version = "0.5.0";
            propagatedBuildInputs = with ps; [ aiohttp xmltodict pytz ];
            src = ps.fetchPypi {
              inherit pname version;
              sha256 = "0j0rl81xdmdi13krdrmzyfk5shviq8czfs1xgr0100i0jm258cp5";
            };
          }
        )
        ps.pynacl
        ps.ssdp
        ps.zeroconf
      ];
    };
  };

}
