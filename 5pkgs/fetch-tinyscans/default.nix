{ writers, python3Packages }:

writers.writePython3Bin "fetch-tinyscans" {
  libraries = with python3Packages; [
    click
    pillow
    requests
  ];
  flakeIgnore = [ "E501" ]; # line length (black)
} (builtins.readFile ./fetch-tinyscans.py)
