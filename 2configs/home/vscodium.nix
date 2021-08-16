{ config, lib, pkgs, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.ptsd-vscodium;
    userSettings = {
      "editor.fontFamily" = "'SauceCodePro Nerd Font'";
      "gitlens.advanced.telemetry.enabled" = false;
      "[nix]"."editor.tabSize" = 2;
      "update.channel" = "none";
      "workbench.startupEditor" = "newUntitledFile";
      "update.mode" = "none";
      "git.confirmSync" = false;
      "git.enableSmartCommit" = true;
    };
    extensions = with pkgs.vscode-extensions; [
      eamodio.gitlens
      editorconfig.editorconfig
      jnoortheen.nix-ide
      ms-python.python
    ];
  };
}