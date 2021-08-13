{ config, lib, pkgs, ... }:

let
  babelfishTranslate = path: name:
    pkgs.runCommand "${name}.fish"
      {
        nativeBuildInputs = [ pkgs.babelfish ];
      } "${pkgs.babelfish}/bin/babelfish < ${path} > $out;";
in
{
  # faster than hm default fenv sourcing
  xdg.configFile."fish/config.fish".text =
    let
      hm-session-vars = pkgs.writeText "hm-session-vars.sh" (config.lib.shell.exportAll config.home.sessionVariables);
    in
    ''
      if not set -q __fish_general_config_sourced
        source ${babelfishTranslate hm-session-vars "hm-session-vars"} > /dev/null
        set -g __fish_general_config_sourced 1
      end
    '' + lib.optionalString config.wayland.windowManager.sway.enable ''
      if status is-login
        if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
          # pass sway log output to journald
          exec ${pkgs.systemd}/bin/systemd-cat --identifier=sway ${pkgs.sway}/bin/sway --my-next-gpu-wont-be-nvidia
        end
      end    
    '';
}
