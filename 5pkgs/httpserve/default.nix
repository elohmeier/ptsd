{ writers }:

writers.writePython3Bin "httpserve"
{
  flakeIgnore = [ "E501" ]; # line length (black)
}
  (builtins.readFile ./httpserve.py)
