p@{ config, lib, pkgs, ... }:

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
    };

    interactiveShellInit =
      let
        ls_colors_dark = pkgs.runCommandNoCC "ls_colors_dark" { } ''
          ${pkgs.vivid}/bin/vivid generate molokai > $out
        '';
        ls_colors_light = pkgs.runCommandNoCC "ls_colors_light" { } ''
          ${pkgs.vivid}/bin/vivid generate ayu > $out
        '';
      in
      ''
        set -U fish_greeting
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

        set -l DARK_MODE 1
      ''
      +
      lib.optionalString pkgs.stdenv.isDarwin ''
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
      +
      ''
        if [ $DARK_MODE -eq 1 ]
          source ${pkgs.vimPlugins.tokyonight-nvim}/extras/fish/tokyonight_night.fish
          set -gx LS_COLORS (cat ${ls_colors_dark})
        else
          source ${pkgs.vimPlugins.tokyonight-nvim}/extras/fish/tokyonight_day.fish
          set -gx LS_COLORS (cat ${ls_colors_light})
        end
      '';

    plugins = with pkgs.fishPlugins; [
      { name = "fzf"; inherit (fzf-fish) src; }
      { name = "tide"; src = tide.src; }
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

  home.packages = with pkgs; [ eza fd fzf-no-fish ];

  home.file.".config/fish/functions".source = if (builtins.hasAttr "nixosConfig" p) then ../../src/fish else config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/fish";

}
