{ ... }:

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
    ignores = [ "*~" "*.swp" ".ipynb_checkpoints/" ];
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
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-decoration-style = "none";
          file-style = "bold yellow ul";
        };
        features = "decorations";
        whitespace-error-style = "22 reverse";
        #paging = "never";
      };
    };
  };
}
