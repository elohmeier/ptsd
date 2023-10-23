{ pkgs, ... }: {

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _pkg: true; # https://github.com/nix-community/home-manager/issues/2942
  };

  home.packages = with pkgs; [
    bchunk
    firefox
    xarchiver
    zathura
  ];

  home = {
    username = "gordon";
    homeDirectory = "/home/gordon";
  };
}

