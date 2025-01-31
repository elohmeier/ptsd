{ pkgs, ... }:

{
  home = {
    username = "root";
    homeDirectory = "/root";
    stateVersion = "24.11";
    packages = [
      pkgs.btop
      pkgs.ghostty.terminfo
      pkgs.nixfmt-rfc-style
      pkgs.nixvim-minimal
      pkgs.ruff
      pkgs.taplo
      pkgs.uv
    ];
    sessionVariables = {
      EDITOR = "nvim";
      TERMINFO_DIRS = "/root/.nix-profile/share/terminfo:/etc/terminfo:/lib/terminfo:/usr/share/terminfo";
      PATH = "/nix/var/nix/profiles/default/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin /usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/nix/var/nix/profiles/default/bin";
    };
  };

  programs.fish = {
    shellAbbrs = {
      e = "nvim";
    };
  };
}
