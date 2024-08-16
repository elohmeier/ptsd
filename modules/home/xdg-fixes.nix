{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = [ pkgs.xdg-ninja ];
  xdg.enable = true;

  home.sessionVariables = with config.xdg; {
    CARGO_HOME = "${dataHome}/cargo";
    # GNUPGHOME = "${dataHome}/gnupg";
    IPYTHONDIR = "${configHome}/ipython";
    JUPYTER_CONFIG_DIR = "${configHome}/jupyter";
    LESSHISTFILE = "${cacheHome}/less/history";
    TERMINFO = "${dataHome}/terminfo";
    NODE_REPL_HISTORY = "${dataHome}/node_repl_history";
    NPM_CONFIG_USERCONFIG = "${configHome}/npm/npmrc";
    KERAS_HOME = "${stateHome}/keras";
    PYTHONSTARTUP = pkgs.writeText "pythonstartup.py" ''
      import os
      import atexit
      import readline

      history = os.path.join(os.environ['XDG_CACHE_HOME'], 'python_history')
      try:
          readline.read_history_file(history)
      except OSError:
          pass

      def write_history():
          try:
              readline.write_history_file(history)
          except OSError:
              pass

      atexit.register(write_history)
    '';
  };

  home.activation.createInitialNpmrc =
    let
      defaultNpmrc = pkgs.writeText "npmrc" ''
        prefix=${config.xdg.dataHome}/npm
        cache=${config.xdg.cacheHome}/npm
        init-module=${config.xdg.configHome}/npm/config/npm-init.js
      '';
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f ${config.xdg.configHome}/npm/npmrc ]; then
        mkdir -p ${config.xdg.configHome}/npm
        cp ${defaultNpmrc} ${config.xdg.configHome}/npm/npmrc
        chmod 600 ${config.xdg.configHome}/npm/npmrc
      fi
    '';
}
