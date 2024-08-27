{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    package = pkgs.git;
    userName = "Enno Richter";
    userEmail = "enno@nerdworks.de";
    signing = {
      key = "0x807BC3355DA0F069";
      signByDefault = false;
    };
    ignores = [
      "*.sqlite3-journal"
      "*.swp"
      "*~"
      ".DS_Store"
      ".aider*"
      ".direnv/"
      ".ipynb_checkpoints/"
    ];
    extraConfig = {
      init.defaultBranch = "master";
      pull = {
        rebase = false;
        ff = "only";
      };
    };
    delta = {
      enable = true;
      options = {
        whitespace-error-style = "22 reverse";

        # # https://github.com/folke/tokyonight.nvim/blob/main/extras/delta/tokyonight_night.gitconfig
        # minus-style = "syntax \"#37222c\"";
        # minus-non-emph-style = "syntax \"#37222c\"";
        # minus-emph-style = "syntax \"#713137\"";
        # minus-empty-line-marker-style = "syntax \"#37222c\"";
        # line-numbers-minus-style = "#b2555b";
        # plus-style = "syntax \"#20303b\"";
        # plus-non-emph-style = "syntax \"#20303b\"";
        # plus-emph-style = "syntax \"#2c5a66\"";
        # plus-empty-line-marker-style = "syntax \"#20303b\"";
        # line-numbers-plus-style = "#266d6a";
        # line-numbers-zero-style = "#3b4261";

        # https://github.com/folke/tokyonight.nvim/blob/main/extras/delta/tokyonight_day.gitconfig
        minus-style = "syntax \"#dfccd4\"";
        minus-non-emph-style = "syntax \"#dfccd4\"";
        minus-emph-style = "syntax \"#d99ea2\"";
        minus-empty-line-marker-style = "syntax \"#dfccd4\"";
        line-numbers-minus-style = "#c25d64";
        plus-style = "syntax \"#aecde6\"";
        plus-non-emph-style = "syntax \"#aecde6\"";
        plus-emph-style = "syntax \"#57a7bc\"";
        plus-empty-line-marker-style = "syntax \"#aecde6\"";
        line-numbers-plus-style = "#399a96";
        line-numbers-zero-style = "#a8aecb";
      };
    };
    lfs.enable = true;
  };

  home.packages = [ pkgs.gitAndTools.git-absorb ];
}
