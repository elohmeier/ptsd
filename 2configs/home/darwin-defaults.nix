{ config, lib, pkgs, ... }: {

  targets.darwin.defaults = {
    NSGlobalDomain = {
      # faster key repeat
      InitialKeyRepeat = 15; # default: 68
      KeyRepeat = 1; # default: 6
    };

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv"; # list view
    };
  };
}
