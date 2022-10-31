{ config, lib, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    useBabelfish = true;

    shellAliases = {
      gaapf = "git add . && git commit --amend --no-edit && git push --force";
      gapf = "git commit --amend --no-edit && git push --force";
      grep = "grep --color";
      jq = "jaq";
      l = "exa -al";
      la = "exa -al";
      lg = "exa -al --git";
      ll = "exa -l";
      ls = "exa";
      ping6 = "ping -6";
      slvpn-set-dns = "sudo busctl call org.freedesktop.resolve1 /org/freedesktop/resolve1 org.freedesktop.resolve1.Manager SetLinkDNS 'ia(iay)' (ip -j link show dev tun0 | jq '.[0].ifindex') 1 2 4 172 16 0 1 && resolvectl status tun0";
      telnet = "screen //telnet";
      tree = "exa --tree";
      vi = "nvim";
      vim = "nvim";
    };

    shellAbbrs = {
      "cd.." = "cd ..";
      "ga." = "git add .";
      br = "broot";
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gd = "git diff";
      gf = "git fetch";
      gl = "git log";
      gp = "git pull";
      gpp = "git push";
      gs = "git status";
    };

    interactiveShellInit = ''
      set -U fish_greeting
      source ${../../4scripts/iterm2-integration.fish}
    '' + lib.optionalString config.wayland.windowManager.sway.enable ''
      if status is-login
        if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
          # pass sway log output to journald
          exec ${pkgs.systemd}/bin/systemd-cat --identifier=sway ${pkgs.sway}/bin/sway --unsupported-gpu
        end
      end
    '';

    plugins = with pkgs.fishPlugins; [
      #{ name = "done"; src = done.src; } # disabled, now solved via iterm2 integration
      { name = "fzf"; inherit (fzf-fish) src; }
    ];
  };

  programs.zoxide.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.packages = with pkgs; [ exa ];
}
