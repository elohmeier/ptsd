{ ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = ''
      # pane movement
      bind-key j command-prompt -p "join pane from:"  "join-pane -s '%%'"
      bind-key s command-prompt -p "send pane to:"  "join-pane -t '%%'"
    '';
  };
}
