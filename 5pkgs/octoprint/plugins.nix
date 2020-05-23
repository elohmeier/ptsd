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

  bedlevelvisualizer = buildPlugin rec {
    pname = "BedLevelVisualizer";
    version = "0.1.13";

    src = fetchFromGitHub {
      owner = "jneilliii";
      repo = "OctoPrint-BedLevelVisualizer";
      rev = version;
      sha256 = "0cn8zwcrxbdn7qqma4291x89bz4y3cmk6x52pa2awambzj565lfq";
    };

    propagatedBuildInputs = with super; [ numpy ];
  };

}
