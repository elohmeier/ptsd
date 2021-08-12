{ config, pkgs, ... }:

{
  # faster than hm default fenv sourcing
  xdg.configFile."fish/config.fish".text =
    let
      hm-session-vars = pkgs.writeText "hm-session-vars.sh" ''
        ${config.lib.shell.exportAll config.home.sessionVariables}
      '';
      babelfishTranslate = path: name:
        pkgs.runCommand "${name}.fish"
          {
            nativeBuildInputs = [ pkgs.babelfish ];
          } "${pkgs.babelfish}/bin/babelfish < ${path} > $out;";
    in
    "source ${babelfishTranslate hm-session-vars "hm-session-vars"} > /dev/null";
}
