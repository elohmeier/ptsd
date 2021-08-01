{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.cli;
  shellAliases = import ../2configs/aliases.nix;

  nnn-custom = pkgs.nnn.override {
    withNerdIcons = true;
  };
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

      environment.systemPackages = with pkgs; [
        bc
        bind
        bridge-utils
        file
        htop
        httpserve
        iftop
        iotop
        jq
        killall
        libfaketime
        ncdu
        nmap
        pwgen
        rmlint
        screen
        tig
        unzip
        #vims.big
        wget
        shellcheck
        nixpkgs-fmt
        gnumake
        #(pass.withExtensions (ext: [ ext.pass-import ]))
        pass
        openssl
        lorri
        smartmontools
        gptfdisk
        parted
        usbutils
        wirelesstools
        wpa_supplicant
        macchanger
        p7zip
        unrar
        mosh
        mkpasswd
        netcat-gnu
        nwbackup-env
        nix-index
        ptsdbootstrap
        nnn-custom
        bat
      ];

      home-manager.users = (listToAttrs (map
        (
          user: {
            name = user;
            value = { pkgs, ... }: {
              home.sessionVariables = {
                EDITOR = "vim";
                NNN_PLUG = "i:nobbofin-insert";
              };

              home.file.".config/nnn/plugins/nobbofin-insert".source = "${pkgs.ptsd-python3.pkgs.nobbofin}/bin/nobbofin-insert";

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
                      paging = "never";
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
                  defaultCommand = "${pkgs.fd}/bin/fd --type f";
                  fileWidgetCommand = "${pkgs.fd}/bin/fd --type f";
                  fileWidgetOptions = [ "--preview '${pkgs.bat}/bin/bat -r :20 --color always {}'" ];
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
                    set booted (readlink /run/booted-system/{initrd,kernel,kernel-modules})
                    set built (readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})
                    if test "$booted" != "$built"
                      echo "please reboot"
                    end
                  '';
                  functions = {
                    posix-source = ''
                      for i in (cat $argv)
                        set arr (echo $i |tr = \n)
                          set -gx $arr[1] $arr[2]
                      end
                    '';

                    # src: https://github.com/jarun/nnn/blob/master/misc/quitcd/quitcd.fish
                    n = ''
                      function n --wraps nnn --description 'support nnn quit and change directory'
                        # Block nesting of nnn in subshells
                        if test -n "$NNNLVL"
                          if [ (expr $NNNLVL + 0) -ge 1 ]
                            echo "nnn is already running"
                            return
                          end
                        end

                        # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
                        # To cd on quit only on ^G, remove the "-x" as in:
                        #    set NNN_TMPFILE "$XDG_CONFIG_HOME/nnn/.lastd"
                        # NOTE: NNN_TMPFILE is fixed, should not be modified
                        if test -n "$XDG_CONFIG_HOME"
                          set -x NNN_TMPFILE "$XDG_CONFIG_HOME/nnn/.lastd"
                        else
                          set -x NNN_TMPFILE "$HOME/.config/nnn/.lastd"
                        end

                        # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
                        # stty start undef
                        # stty stop undef
                        # stty lwrap undef
                        # stty lnext undef

                        ${nnn-custom}/bin/nnn $argv

                        if test -e $NNN_TMPFILE
                          source $NNN_TMPFILE
                          rm $NNN_TMPFILE
                        end
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


                neovim = {
                  enable = true;
                  viAlias = true;
                  vimAlias = true;
                  vimdiffAlias = true;
                  withRuby = false;
                  withPython3 = true;
                  extraPython3Packages = ps: with ps; [ python-language-server ];
                  plugins = with pkgs.vimPlugins; [
                    vim-nix # TODO: rm when tree-sitter-nix works
                    #nnn-vim
                    vim-css-color
                    {
                      plugin = (nvim-treesitter.withPlugins (plugins: with plugins; [
                        tree-sitter-go
                        tree-sitter-nix
                        tree-sitter-python
                      ]));
                      config = ''
                        lua <<EOF
                          require'nvim-treesitter.configs'.setup {
                            highlight = {
                              enable = true,
                              additional_vim_regex_highlighting = false,
                            },
                          }
                        EOF
                      '';
                    }
                    {
                      plugin = nvim-lspconfig;
                      config = ''
                        lua <<EOF
                        require'lspconfig'.gopls.setup{
                          cmd = { "${pkgs.gopls}/bin/gopls" },
                        }
                        require'lspconfig'.rnix.setup{
                          cmd = { "${pkgs.rnix-lsp}/bin/rnix-lsp" },
                        }
                        require'lspconfig'.pyright.setup{
                          cmd = { "${pkgs.pyright}/bin/pyright-langserver", "--stdio" },
                        }
                        EOF'';
                    }
                    {
                      plugin = nvim-tree-lua;
                      config = "map <C-n> :NvimTreeToggle<CR>";
                    }
                    {
                      plugin = hop-nvim;
                      config = ''
                        nnoremap <leader>hl :HopLine<CR>
                      '';
                    }
                    {
                      plugin = nvim-compe;
                      config = ''
                        lua << EOF
                        vim.o.completeopt = "menuone,noselect"
                        require'compe'.setup({
                          enabled = true,
                          source = {
                            path = true,
                            buffer = true,
                            nvim_lsp = true,
                          },
                        })
                        EOF

                        inoremap <silent><expr> <C-Space> compe#complete()
                        inoremap <silent><expr> <CR>      compe#confirm('<CR>')
                        inoremap <silent><expr> <C-e>     compe#close('<C-e>')
                        inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
                        inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })
                      '';
                    }
                    {
                      plugin = formatter-nvim;
                      config = ''
                        lua << EOF
                          require('formatter').setup({
                            filetype = {
                              go = {
                                function()
                                  return {
                                    exe = "${pkgs.go}/bin/gofmt",
                                    stdin = true
                                  }
                                end
                              },
                              html = {
                                function()
                                  return {
                                    exe = "${pkgs.nodePackages.prettier}/bin/prettier",
                                    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote'},
                                    stdin = true,
                                  }
                                  end
                              },
                              javascript = {
                                function()
                                  return {
                                    exe = "${pkgs.nodePackages.prettier}/bin/prettier",
                                    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0), '--single-quote'},
                                    stdin = true,
                                  }
                                  end
                              },
                              nix = {
                                function()
                                  return {
                                    exe = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt",
                                    stdin = true
                                  }
                                end
                              },
                              python = {
                                function()
                                  return {
                                    exe = "${pkgs.python3Packages.black}/bin/black",
                                    args = {"-"},
                                    stdin = true
                                  }
                                end
                              }
                            }
                          })
                        EOF
                        nnoremap <silent> <leader>i :Format<CR>
                      '';
                    }
                    {
                      plugin = telescope-nvim;
                      config = ''
                        nnoremap <leader>ff <cmd>Telescope find_files<cr>
                        nnoremap <leader>fg <cmd>Telescope live_grep<cr>
                        nnoremap <leader>fb <cmd>Telescope buffers<cr>
                        nnoremap <leader>fh <cmd>Telescope help_tags<cr>
                      '';
                    }
                    {
                      plugin = lualine-nvim;
                      config = ''
                        lua << EOF
                          require('lualine').setup()
                        EOF
                      '';
                    }
                    neorg
                  ];
                };
              };

              home.packages = with pkgs; [
                nix-zsh-completions
                pueue
                yank
              ];
            };
          }
        )
        cfg.users
      ));
    };
}
