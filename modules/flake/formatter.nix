{ ... }:
{
  perSystem =
    { pkgs, system, ... }:
    {
      treefmt.config = {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
        programs.ruff.enable = true;
        programs.shellcheck.enable = true;
        programs.shfmt.enable = true;
      };
    };
}
