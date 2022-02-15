{ config, lib, pkgs, ... }:
{
  programs.vscode = {
    enable = pkgs.stdenv.hostPlatform.system != "aarch64-linux";
    package = pkgs.vscode;
    userSettings = {
      "[nix]" = {
        "editor.tabSize" = 2;
      };
      "[typescript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[typescriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "editor.fontFamily" = "'SauceCodePro Nerd Font'";
      "git.confirmSync" = false;
      "git.enableSmartCommit" = true;
      "gitlens.advanced.telemetry.enabled" = false;
      "telemetry.enableCrashReporter" = false;
      "telemetry.enableTelemetry" = false;
      "telemetry.telemetryLevel" = "off";
      "update.channel" = "none";
      "update.mode" = "none";
      "workbench.startupEditor" = "newUntitledFile";
      "typescript.updateImportsOnFileMove.enabled" = "always";
      "explorer.confirmDragAndDrop" = false;
      "javascript.updateImportsOnFileMove.enabled" = "always";
      "editor.inlineSuggest.enabled" = true;
      "window.zoomLevel" = 2;
      "workbench.colorTheme" = "Default High Contrast";
    };
    extensions = with pkgs.vscode-extensions; [
      eamodio.gitlens
      editorconfig.editorconfig
      esbenp.prettier-vscode
      github.copilot
      jkillian.custom-local-formatters
      jnoortheen.nix-ide
      ms-python.python
      ms-toolsai.jupyter
      ms-vscode-remote.remote-ssh
      ms-vscode.cpptools
    ];
  };
}
