p@{
  config,
  lib,
  pkgs,
  ...
}:

let
  rose-pine-fish = pkgs.fetchFromGitHub {
    owner = "rose-pine";
    repo = "fish";
    rev = "38aab5baabefea1bc7e560ba3fbdb53cb91a6186";
    hash = "sha256-bSGGksL/jBNqVV0cHZ8eJ03/8j3HfD9HXpDa8G/Cmi8=";
  };
in
{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      enter_accept = false;
      invert = true;
      sync_address = "http://100.92.45.113:8888"; # htz2
    };
  };

  programs.fish = {
    enable = true;

    shellAliases = {
      gaapf = "git add . && git commit --amend --no-edit && git push --force-with-lease";
      gapf = "git commit --amend --no-edit && git push --force-with-lease";
      gg = "gitu";
      grep = "grep --color";
      l = "eza -al";
      la = "eza -al";
      lg = "eza -al --git";
      lgg = "lazygit";
      ll = "eza -l";
      ls = "eza";
      nbconvert = "jupyter nbconvert --to script --stdout";
      ping6 = lib.mkIf pkgs.stdenv.isLinux "ping -6";
      slvpn-set-dns = "sudo busctl call org.freedesktop.resolve1 /org/freedesktop/resolve1 org.freedesktop.resolve1.Manager SetLinkDNS 'ia(iay)' (ip -j link show dev tun0 | jq '.[0].ifindex') 1 2 4 172 16 0 1 && resolvectl status tun0";
      telnet = "screen //telnet";
      tree = "eza --tree";
      vi = "nvim";
      vim = "nvim";
    };

    shellAbbrs = {
      "cd.." = "cd ..";
      "ga." = "git add .";
      br = "broot";
      etm = "et -c \"tmux -CC new -A -s main\"";
      ga = "git add";
      gb = "git branch";
      gc = "git commit";
      gcf = "git commit --fixup";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gd = "git diff";
      gf = "git fetch";
      gl = "git log";
      gp = "git pull";
      gpp = "git push";
      gst = "git status";
      kc = "kubectl";
      nb = "nix build";
      nf = "nix flake";
      nfl = "nix flake lock";
      nfu = "nix flake update";
      nr = "nix run";
      rga = "rg -a.";
      rgi = "rg -i";
      rgia = "rg -ia.";
    };

    interactiveShellInit =
      let
        # cache vivid output in the store
        ls_colors_dark = pkgs.runCommandNoCC "ls_colors_dark" { } ''
          ${pkgs.vivid}/bin/vivid generate tokyonight-night > $out
        '';
        ls_colors_light = pkgs.runCommandNoCC "ls_colors_light" { } ''
          ${pkgs.vivid}/bin/vivid generate ayu > $out
        '';

        # generate tide config into a file containing key-value pairs
        # example output:
        # tide_aws_bg_color normal
        # tide_aws_color yellow
        # ...
        tidecfg =
          let
            script = pkgs.writeText "tide-configure-fish.fish" ''
              set fish_function_path ${pkgs.fishPlugins.tide}/share/fish/vendor_functions.d $fish_function_path

              tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time='24-hour format' --lean_prompt_height='One line' --prompt_spacing=Compact --icons='Few icons' --transient=No
            '';
          in
          pkgs.runCommandNoCC "tidecfg" { } ''
            HOME=$(mktemp -d)
            ${pkgs.fish}/bin/fish ${script}
            ${pkgs.fish}/bin/fish -c "set -U --long" > $out
          '';
      in
      ''
        set -g fish_greeting
        source ${../../scripts/iterm2-integration.fish}
        fzf_configure_bindings --directory=\ct

        function h
          set _h_dir (${pkgs.h}/bin/h --resolve "${config.home.homeDirectory}/repos" $argv)
          set _h_ret $status
          if test "$_h_dir" != "$PWD"
            cd "$_h_dir"
          end
          return $_h_ret
        end

        # Check if tide is configured by checking one of the variables
        if not set -q tide_aws_bg_color
          # Load the tide configuration from the generated file
          echo "Loading tide configuration (only once)" >&2
          for line in (cat ${tidecfg})
            # tide only works with universal variables
            eval "set -U $line"
          end
        end

        set -l DARK_MODE 1
      ''
      + lib.optionalString pkgs.stdenv.isDarwin ''
        # read AppleInterfaceStyle from defaults
        # for Dark mode, the exit code is 0 and the content is "Dark"
        # for Light mode, the exit code is 1 and a error message is shown
        defaults read -g AppleInterfaceStyle &>/dev/null
        if test $status -eq 0
          set -l DARK_MODE 1
        else
          set -l DARK_MODE 0
        end
      ''
      + ''
        if [ $DARK_MODE -eq 1 ]
          # fish_config theme choose "Rosé Pine"
          fish_config theme choose "TokyoNight Night"
          set -gx LS_COLORS (cat ${ls_colors_dark})
          set -gx AICHAT_LIGHT_THEME 0
        else
          # fish_config theme choose "Rosé Pine Dawn"
          fish_config theme choose "TokyoNight Day"
          set -gx LS_COLORS (cat ${ls_colors_light})
          set -gx AICHAT_LIGHT_THEME 1
        end
      '';

    plugins = with pkgs.fishPlugins; [
      {
        name = "fzf";
        inherit (fzf-fish) src;
      }
      {
        name = "tide";
        src = tide.src;
      }
    ];
  };

  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    stdlib = ''
      layout_poetry() {
          PYPROJECT_TOML="''${PYPROJECT_TOML:-pyproject.toml}"
          if [[ ! -f "$PYPROJECT_TOML" ]]; then
              log_status "No pyproject.toml found. Executing \`poetry init\` to create a \`$PYPROJECT_TOML\` first."
              poetry init
          fi

          if [[ -d ".venv" ]]; then
              VIRTUAL_ENV="$(pwd)/.venv"
          else
              VIRTUAL_ENV=$(poetry env info --path 2>/dev/null ; true)
          fi

          if [[ -z $VIRTUAL_ENV || ! -d $VIRTUAL_ENV ]]; then
              log_status "No virtual environment exists. Executing \`poetry install\` to create one."
              poetry install
              VIRTUAL_ENV=$(poetry env info --path)
          fi

          PATH_add "$VIRTUAL_ENV/bin"
          export POETRY_ACTIVE=1  # or VENV_ACTIVE=1
          export VIRTUAL_ENV
      }
    '';
  };

  home.packages = with pkgs; [
    eza
    fd
    fzf-no-fish
  ];

  home.file.".config/fish/functions".source =
    if (builtins.hasAttr "nixosConfig" p) then
      ../../src/fish
    else
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/fish";

  home.file.".config/fish/themes/Rosé Pine.theme".source = "${rose-pine-fish}/themes/Rosé Pine.theme";
  home.file.".config/fish/themes/Rosé Pine Dawn.theme".source = "${rose-pine-fish}/themes/Rosé Pine Dawn.theme";

  home.file.".config/fish/themes/TokyoNight Night.theme".text = ''
    # Upstream: https://github.com/folke/tokyonight.nvim/blob/main/extras/fish/tokyonight_night.fish
    # Syntax Highlighting Colors
    fish_color_normal c0caf5
    fish_color_command 7dcfff
    fish_color_keyword bb9af7
    fish_color_quote e0af68
    fish_color_redirection c0caf5
    fish_color_end ff9e64
    fish_color_error f7768e
    fish_color_param 9d7cd8
    fish_color_comment 565f89
    fish_color_selection --background=283457
    fish_color_search_match --background=283457
    fish_color_operator 9ece6a
    fish_color_escape bb9af7
    fish_color_autosuggestion 565f89

    # Completion Pager Colors
    fish_pager_color_progress 565f89
    fish_pager_color_prefix 7dcfff
    fish_pager_color_completion c0caf5
    fish_pager_color_description 565f89
    fish_pager_color_selected_background --background=283457
  '';

  home.file.".config/fish/themes/TokyoNight Day.theme".text = ''
    # Upstream: https://github.com/folke/tokyonight.nvim/blob/main/extras/fish/tokyonight_day.fish
    # Syntax Highlighting Colors
    fish_color_normal 3760bf
    fish_color_command 007197
    fish_color_keyword 9854f1
    fish_color_quote 8c6c3e
    fish_color_redirection 3760bf
    fish_color_end f52a65
    fish_color_error f52a65
    fish_color_param 7847bd
    fish_color_comment 848cb5
    fish_color_selection --background=b7c1e3
    fish_color_search_match --background=b7c1e3
    fish_color_operator 587539
    fish_color_escape 9854f1
    fish_color_autosuggestion 848cb5

    # Completion Pager Colors
    fish_pager_color_progress 848cb5
    fish_pager_color_prefix 007197
    fish_pager_color_completion 3760bf
    fish_pager_color_description 848cb5
    fish_pager_color_selected_background --background=b7c1e3
  '';
}
