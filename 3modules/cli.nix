{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.cli;
  shellAliases = import ../2configs/aliases.nix;
in
{
  options = {
    ptsd.cli = {
      enable = mkEnableOption "cli";
      defaultShell = mkOption {
        type = types.enum [ "zsh" "fish" ];
        default = "zsh";
      };
      users = mkOption {
        type = with types; listOf str;
        default = [ "mainUser" ];
      };
      fish.enable = mkOption {
        type = types.bool;
        default = false;
      };
      zsh.enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable
    {

      programs.fish.enable = cfg.defaultShell == "fish";

      # Make sure zsh lands in /etc/shells
      # to not be affected by user not showing up in LightDM
      # as in https://discourse.nixos.org/t/normal-users-not-appearing-in-login-manager-lists/4619
      programs.zsh.enable = cfg.defaultShell == "zsh";

      users.users =
        (
          listToAttrs
            (
              map
                (
                  user: {
                    name = user;
                    value = { shell = { "zsh" = pkgs.zsh; "fish" = pkgs.fish; }."${cfg.defaultShell}"; };
                  }
                )
                cfg.users
            )
        );

      # as recommended in
      # https://github.com/rycee/home-manager/blob/master/modules/programs/zsh.nix
      environment.pathsToLink =
        mkIf
          (cfg.defaultShell == "zsh") [ "/share/zsh" ];

      home-manager.users = (listToAttrs (map
        (
          user: {
            name = user;
            value = { pkgs, ... }: {
              home.sessionVariables = {
                EDITOR = "vim";
              };



              programs = {

                git = {
                  enable = true;
                  package = pkgs.git;
                  userName = "Enno Richter";
                  userEmail = "enno@nerdworks.de";
                  signing = {
                    key = "0x807BC3355DA0F069";
                    signByDefault = false;
                  };
                  ignores = [ "*~" "*.swp" ".ipynb_checkpoints/" ];
                  extraConfig = {
                    init.defaultBranch = "master";
                    pull = {
                      rebase = false;
                      ff = "only";
                    };
                  };
                  delta = {
                    enable = true;
                    options = {
                      decorations = {
                        commit-decoration-style = "bold yellow box ul";
                        file-decoration-style = "none";
                        file-style = "bold yellow ul";
                      };
                      features = "decorations";
                      whitespace-error-style = "22 reverse";
                    };
                  };
                };

                tmux = {
                  enable = true;
                  clock24 = true;
                  extraConfig = ''
                    # pane movement
                    bind-key j command-prompt -p "join pane from:"  "join-pane -s '%%'"
                    bind-key s command-prompt -p "send pane to:"  "join-pane -t '%%'"
                  '';
                  plugins = [
                    {
                      plugin = pkgs.tmuxPlugins.vim-tmux-navigator;
                      extraConfig = ''
                        # Smart pane switching with awareness of Vim splits.
                        # See: https://github.com/christoomey/vim-tmux-navigator
                        is_vim="${pkgs.procps}/bin/ps -o state= -o comm= -t '#{pane_tty}' \
                            | ${pkgs.gnugrep}/bin/grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
                        bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
                        bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
                        bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
                        bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
                        tmux_version='$(${pkgs.tmux}/bin/tmux -V | ${pkgs.gnused}/bin/sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
                        if-shell -b '[ "$(echo "$tmux_version < 3.0" | ${pkgs.bc}/bin/bc)" = 1 ]' \
                            "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
                        if-shell -b '[ "$(echo "$tmux_version >= 3.0" | ${pkgs.bc}/bin/bc)" = 1 ]' \
                            "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

                        bind-key -T copy-mode-vi 'C-h' select-pane -L
                        bind-key -T copy-mode-vi 'C-j' select-pane -D
                        bind-key -T copy-mode-vi 'C-k' select-pane -U
                        bind-key -T copy-mode-vi 'C-l' select-pane -R
                        bind-key -T copy-mode-vi 'C-\' select-pane -l
                      '';
                    }
                  ];
                };
                direnv = {
                  enable = true;
                };

                fzf = {
                  enable = true;
                };

                z-lua = {
                  enable = true;
                };

                fish = mkIf cfg.fish.enable {
                  enable = true;
                  shellAliases = (import ../2configs/aliases.nix).aliases;
                  shellAbbrs = (import ../2configs/aliases.nix).abbreviations;
                  interactiveShellInit = ''
                    set -U fish_greeting
                  '';
                  functions = {
                    posix-source = ''
                      for i in (cat $argv)
                        set arr (echo $i |tr = \n)
                          set -gx $arr[1] $arr[2]
                      end
                    '';
                  };
                };

                starship = {
                  enable = true;
                  settings = {
                    aws.disabled = true;
                  };
                };

                zsh = mkIf cfg.zsh.enable {
                  enable = true;
                  enableCompletion = true;

                  initExtra = ''
                    if [ "$TERM" != dumb ]; then
                      autoload -U colors && colors

                      # green bold user name
                      #PS1="%B%(?..[%?] )%b%(!.%{$fg_bold[red]%}%m.%{$fg_bold[green]%}%n@%m) %{$fg_bold[blue]%}%~%{$reset_color%} "

                      # red bold user name
                      #PS1="%B%(?..[%?] )%b%(!.%{$fg_bold[red]%}%m.%{$fg_bold[red]%}%n@%m) %{$fg_bold[red]%}%~%{$reset_color%} "

                      # red regular user name
                      PS1="%B%(?..[%?] )%b%(!.%{$fg[red]%}%m.%{$fg[red]%}%n@%m) %{$fg[red]%}%~%{$reset_color%} "

                      function preexec() {
                        timer=''${timer:-$SECONDS}
                      }

                      function precmd() {
                        if [ $timer ]; then
                          timer_show=$(($SECONDS - $timer))
                          if [ $timer_show -lt 2 ]; then
                            export RPROMPT=""
                          else
                            export RPROMPT="%F{cyan}''${timer_show}s %{$reset_color%}"
                          fi
                          unset timer
                        fi
                      }

                      # allow any key to get things flowing again (after Ctrl-s)
                      stty ixany

                      # to disable Ctrl-s use this:
                      # stty -ixon

                      # the following bindkey statments
                      # fix the Ctrl-Left/Right keybindings
                      # https://unix.stackexchange.com/questions/58870/ctrl-left-right-arrow-keys-issue/332049#332049

                      # terminator, konsole and xterm (and maybe others):
                      bindkey "^[[1;5C" forward-word
                      bindkey "^[[1;5D" backward-word

                      # urxvt/rxvt-unicode (and maybe others)
                      bindkey "^[Od" backward-word
                      bindkey "^[Oc" forward-word
                      bindkey "^[[1~" beginning-of-line
                      bindkey "^[[4~" end-of-line

                      booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules})"
                      built="$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"

                      if [ "$booted" != "$built" ]; then
                        echo "please reboot"
                      fi

                      # Johnnydecimal.com
                      cjdfunction() {
                        pushd ~/Pocket/*/*/''${1}*
                      }
                      export cjdfunction
                      alias cjd="cjdfunction"
                    fi
                  '';
                  shellAliases = shellAliases.aliases // shellAliases.abbreviations;
                };
              };
              home.packages = with pkgs; [
                python3Packages.graphtage
                nix-zsh-completions
                pueue
                vims.big
                yank
              ];
            };
          }
        )
        cfg.users
      ));
    };
}
