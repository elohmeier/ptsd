{ pkgs ? import <nixpkgs> { } }:
let
  unwrappedArduino = pkgs.arduino;
  fhsarduino = pkgs.buildFHSUserEnv {
    name = "arduino";
    passthru = { inherit (unwrappedArduino) pname version meta; };
    targetPkgs = pkgs: with pkgs; [
      unwrappedArduino
      zlib
      (python3.withPackages (p: with p; [ pyserial ]))
    ];
    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cp ${unwrappedArduino}/share/applications/arduino.desktop $out/share/applications/arduino.desktop
      substituteInPlace $out/share/applications/arduino.desktop \
        --replace ${unwrappedArduino}/bin/arduino $out/bin/arduino
    '';
    runScript = "arduino";
  };
in
pkgs.mkShell {
  buildInputs = with pkgs;[
    avrdude
    python2
    fhsarduino
    platformio
  ];
  shellHook =
    ''
      export PATH=$PATH:${pkgs.arduino}/share/arduino/hardware/tools/avr/bin
    '';
}
