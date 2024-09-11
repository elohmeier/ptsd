{
  inputs,
  lib,
  withSystem,
  ...
}:
let
  darwinSystemFor =
    system: modules:
    let
      pkgs = withSystem system ({ pkgs, ... }: pkgs);
      pkgsUnstable = withSystem system ({ pkgsUnstable, ... }: pkgsUnstable);
    in
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit lib;
      };
      modules = [
        {
          _module.args = {
            pkgs = lib.mkForce pkgs;
            pkgsUnstable = lib.mkForce pkgsUnstable;
          };
        }
      ] ++ modules;
    };
in
{
  flake.darwinModules = { };

  flake.darwinConfigurations = {
    mb4 = darwinSystemFor "aarch64-darwin" [
      # inputs.home-manager.darwinModule
      (
        { pkgs, pkgsUnstable, ... }:
        {
          # home-manager.useGlobalPkgs = true;
          # home-manager.extraSpecialArgs.pkgsUnstable = pkgsUnstable;
          #
          # # username must match the one specified in ./orbstack-defaults/orbstack.nix
          # home-manager.users.enno = { nixosConfig, pkgs, ... }: {
          #   home.stateVersion = nixosConfig.system.stateVersion;
          #   imports = [
          #   ];
          # };

          # do not manage nix-daemon/nix.conf
          nix.useDaemon = true;

          # services.nix-daemon.enable = true;
          # nix.settings.trusted-users = [
          #   "root"
          #   "enno"
          # ];
          # nix.settings.experimental-features = "nix-command flakes";
          # nix.settings.extra-nix-path = "nixpkgs=flake:nixpkgs";

          programs.gnupg.agent.enable = true;

          homebrew = {
            enable = true;
            onActivation = {
              autoUpdate = true;
              upgrade = true;
            };
            brews = [
              "btop"
              "qemu"
              "tesseract"
              "tesseract-lang"
              "uv"

              # iOS/Tauri development
              # "cocoapods"
              # "libimobiledevice"
            ];
            casks = [
              "burp-suite"
              "cleanshot"
              # "coolterm"
              "cursor"
              "db-browser-for-sqlite"
              "dbeaver-enterprise"
              "discord"
              "drawio"
              "element"
              "freecad"
              "gimp"
              "gnucash"
              "google-chrome"
              "inkscape"
              "iterm2"
              "keymapp"
              "libreoffice"
              "logseq"
              "maccy"
              "monitorcontrol"
              "nikitabobko/tap/aerospace"
              "obs"
              "orbstack"
              "portfolioperformance"
              "prusaslicer"
              "raspberry-pi-imager"
              "rectangle"
              "redisinsight"
              "secretive"
              "shortcat"
              "signal"
              "soundsource"
              "spotify"
              "stats"
              "transmission"
              "utm"
              "visual-studio-code"
              "vnc-viewer"
              "sublime-text"
              # "amethyst"
              # "losslesscut"
              # "postman"
              # "texshop"
            ];
            masApps = {
              # Faxbot = 640079107;
              # Tailscale = 1475387142;
            };
          };
        }
      )
    ];
  };
}
