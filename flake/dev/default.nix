{ inputs, ... }:
{
  imports = [
    ./devshell.nix
    inputs.git-hooks.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  perSystem =
    {
      config,
      pkgs,
      system,
      ...
    }:
    {
      treefmt.config = {
        projectRootFile = "flake.nix";
        programs.deadnix.enable = true;
        programs.deadnix.no-lambda-pattern-names = true;
        programs.nixfmt.enable = true;
        programs.ruff.enable = true;
        programs.shellcheck.enable = true;
        programs.shfmt.enable = true;
      };

      checks.git-hooks-check = inputs.git-hooks.lib.${system}.run {
        src = ../../.;
        hooks = {
          treefmt = {
            enable = true;
            package = config.treefmt.build.wrapper;
          };
        };
      };
    };
}
