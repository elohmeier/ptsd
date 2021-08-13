{ config, lib, pkgs, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.ptsd-vscodium;
    userSettings = {
      "editor.fontFamily" = "'SauceCodePro Nerd Font'";
      "git.smartCommitChanges" = "all";
      "gitlens.advanced.telemetry.enabled" = false;
      "[nix]"."editor.tabSize" = 2;
      "update.channel" = "none";
      "workbench.startupEditor" = "none";
    };
    extensions = with pkgs.vscode-extensions; [
      eamodio.gitlens
      editorconfig.editorconfig
      jnoortheen.nix-ide
      ms-python.python
    ];
  };
}
