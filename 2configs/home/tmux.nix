{ ... }: {

  programs.tmux = {
    enable = true;
    clock24 = true;
    escapeTime = 10;
    extraConfig = ''
      set-option -g focus-events on
      set-option -sa terminal-features ',xterm-256color:RGB'
    '';
  };
}
