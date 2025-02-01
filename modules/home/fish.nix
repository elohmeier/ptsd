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
      e = "nvim";
      etm = "et -c \"tmux -CC new -A -s main\"";
      jl = "jupyter lab";
      rga = "rg -a.";
      rgi = "rg -i";
      rgia = "rg -ia.";
      pgen = "pass generate";
      hc = "hcloud";
      y = "yazi";
    };

    interactiveShellInit = ''
      if test "$TERM_PROGRAM" = "iTerm.app"
        source ${../../scripts/iterm2-integration.fish}
      end

      # (ghostty compat) workaround terminal filtering until fix is included in release:
      # https://github.com/fish-shell/fish-shell/commit/cb58a30bf22b031663b40f306beaf6be6698b7c0
      function __fish_update_cwd_osc --on-variable PWD --description 'Notify terminals when $PWD changes'
        printf \e\]7\;file://%s%s\a $hostname (string escape --style=url -- $PWD)
      end
      __fish_update_cwd_osc # Run once because we might have already inherited a PWD from an old

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

  home.file.".config/fish/functions".source =
    if (builtins.hasAttr "nixosConfig" p) then
      ../../src/fish
    else
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/fish";
}
