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
          };
        }
      ] ++ modules;
    };
in
{
  flake.darwinModules = { };

  flake.darwinConfigurations = {
    mb4 = darwinSystemFor "aarch64-darwin" [
      (
        { pkgs, ... }:
        {
          system.stateVersion = 5;

          services.nix-daemon.enable = true;

          nix = {
            package = pkgs.nixVersions.nix_2_24;

            daemonIOLowPriority = true;
            channel.enable = false;

            settings = {
              # defaults from DeterminateSystems/nix-installer
              always-allow-substitutes = true;
              extra-trusted-substituters = "https://cache.flakehub.com";
              extra-trusted-public-keys = "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM= cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio= cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU= cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU= cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8= cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ= cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o= cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y=";
              bash-prompt-prefix = "(nix:$name)\040";
              experimental-features = "nix-command flakes";
              # extra-nix-path = "nixpkgs=flake:nixpkgs";
              upgrade-nix-store-path-url = "https://install.determinate.systems/nix-upgrade/stable/universal";

              # customized
              extra-nix-path = "nixpkgs=flake:${inputs.nixpkgs}";
            };
          };

          programs.gnupg.agent.enable = true;

          homebrew = {
            enable = true;
            onActivation = {
              autoUpdate = true;
              upgrade = true;
            };
            brews = [
              "aichat"
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
              "activitywatch"
              "betterdisplay"
              "burp-suite"
              "cleanshot"
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
              "sublime-text"
              "transmission"
              "utm"
              "visual-studio-code"
              "vnc-viewer"
              # "amethyst"
              # "coolterm"
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
