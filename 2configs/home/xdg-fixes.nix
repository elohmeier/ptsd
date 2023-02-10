{ config, lib, pkgs, ... }:

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
    NPM_CONFIG_USERCONFIG = pkgs.writeText "npmrc" ''
      prefix=${dataHome}/npm
      cache=${cacheHome}/npm
      tmp=${stateHome}/npm
      init-module=${configHome}/npm/config/npm-init.js
    '';
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
}
