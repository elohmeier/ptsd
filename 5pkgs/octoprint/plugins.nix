{ pkgs }:

with pkgs;

self: super: let
  buildPlugin = args: self.buildPythonPackage (
    args // {
      pname = "OctoPrintPlugin-${args.pname}";
      inherit (args) version;
      propagatedBuildInputs = (args.propagatedBuildInputs or []) ++ [ super.octoprint ];
      # none of the following have tests
      doCheck = false;
    }
  );
in
{
  inherit buildPlugin;
}
