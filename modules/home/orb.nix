{ lib, pkgs, ... }:

{
  home.sessionPath = [
    "/opt/orbstack-guest/bin"
  ];

  home.packages = with pkgs; [
    attic-client
    bat
    btop
    cfssl
    colmena
    dive
    gcc
    gotenberg
    hcloud
    hl
    home-manager
    jless
    jq
    kubectl
    nix-tree
    pre-commit
    ripgrep
    rustup
  ];

  programs.fish.interactiveShellInit = lib.mkAfter ''
    # read AppleInterfaceStyle from defaults
    # for Dark mode, the exit code is 0 and the content is "Dark"
    # for Light mode, the exit code is 1 and a error message is shown
    /opt/orbstack-guest/bin/mac defaults read -g AppleInterfaceStyle &>/dev/null
    if test $status -eq 0
      fish_config theme choose "Rosé Pine"
    else
      fish_config theme choose "Rosé Pine Dawn"
    end
  '';
}
