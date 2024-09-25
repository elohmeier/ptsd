p@{
  config,
  lib,
  pkgs,
  ...
}:

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

  # see also nixcfg home fish module
  programs.fish = {
    enable = true;

    shellAliases = {
      gaapf = "git add . && git commit --amend --no-edit && git push --force-with-lease";
      gapf = "git commit --amend --no-edit && git push --force-with-lease";
      grep = "grep --color";
      nbconvert = "jupyter nbconvert --to script --stdout";
      ping6 = lib.mkIf pkgs.stdenv.isLinux "ping -6";
      slvpn-set-dns = "sudo busctl call org.freedesktop.resolve1 /org/freedesktop/resolve1 org.freedesktop.resolve1.Manager SetLinkDNS 'ia(iay)' (ip -j link show dev tun0 | jq '.[0].ifindex') 1 2 4 172 16 0 1 && resolvectl status tun0";
      telnet = "screen //telnet";
    };

    shellAbbrs = {
      br = "broot";
      etm = "et -c \"tmux -CC new -A -s main\"";
      rga = "rg -a.";
      rgi = "rg -i";
      rgia = "rg -ia.";
    };

    interactiveShellInit = ''
      source ${../../scripts/iterm2-integration.fish}

      function h
        set _h_dir (${pkgs.h}/bin/h --resolve "${config.home.homeDirectory}/repos" $argv)
        set _h_ret $status
        if test "$_h_dir" != "$PWD"
          cd "$_h_dir"
        end
        return $_h_ret
      end
    '';
  };

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

  home.file.".config/fish/functions".source =
    if (builtins.hasAttr "nixosConfig" p) then
      ../../src/fish
    else
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/fish";
}
