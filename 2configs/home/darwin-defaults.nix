_: {

  targets.darwin.defaults = {
    "com.apple.dock" = {
      "show-recents" = false;
    };

    "com.apple.loginwindow" = {
      TALLogoutSavesState = false;
      LoginwindowLaunchesRelaunchApps = false;
    };

    "com.apple.finder" = {
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXDefaultSearchScope = "SCcf"; # current folder
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv"; # list view
      FXRemoveOldTrashItems = true;
      _FXSortFoldersFirst = true;
    };

    NSGlobalDomain = {
      # faster key repeat
      InitialKeyRepeat = 15; # default: 68
      KeyRepeat = 1; # default: 6
    };
  };
}
