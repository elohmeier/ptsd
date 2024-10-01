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

  home.file.".config/fish/functions".source =
    if (builtins.hasAttr "nixosConfig" p) then
      ../../src/fish
    else
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/fish";
}
