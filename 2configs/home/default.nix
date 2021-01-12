{ config, lib, pkgs, ... }:

{
  imports = [
    <ptsd/2configs/home/git.nix>
    <ptsd/2configs/home/vim.nix>
    <ptsd/2configs/home/tmux.nix>
    <ptsd/2configs/home/zsh.nix>

    <ptsd/3modules/home>
  ];

  nixpkgs = {
    config.packageOverrides = import ../../5pkgs pkgs;
  };

  home.sessionVariables = {
    PASSWORD_STORE_DIR = "/home/enno/repos/password-store";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  home = {
    file.".mozilla/native-messaging-hosts/passff.json".source = "${pkgs.passff-host}/share/passff-host/passff.json";
    keyboard = {
      layout = "de";
      variant = "nodeadkeys";
    };
    packages = with pkgs;
      [
        zathura
        zathura-single
        (makeDesktopItem {
          name = "zathura";
          desktopName = "Zathura";
          exec = "${pkgs.zathura}/bin/zathura %f";
          mimeType = "application/pdf";
          type = "Application";
        })
        caffeine
        mpv
      ];
  };

  xdg.mimeApps = {
    enable = true;

    # verify using `xdg-mime query default <mimetype>`
    defaultApplications = {
      "application/pdf" = [ "zathura.desktop" ];
      "text/plain" = [ "vim.desktop" ];
      "image/gif" = [ "sxiv.desktop" ];
      "image/jpeg" = [ "sxiv.desktop" ];
      "image/png" = [ "sxiv.desktop" ];
      "inode/directory" = [ "pcmanfm.desktop" ];
      "text/html" = [ "chromium.desktop" "firefox.desktop" ];
      "x-scheme-handler/http" = [ "chromium.desktop" "firefox.desktop" ];
      "x-scheme-handler/https" = [ "chromium.desktop" "firefox.desktop" ];
      "x-scheme-handler/about" = [ "chromium.desktop" "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "chromium.desktop" "firefox.desktop" ];
      "x-scheme-handler/msteams" = [ "teams.desktop" ];
      "application/vnd.jgraph.mxfile" = [ "drawio.desktop" ];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ];
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "calc.desktop" ];
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "impress.desktop" ];
      "application/msword" = [ "writer.desktop" ];
      "application/msexcel" = [ "calc.desktop" ];
      "application/mspowerpoint" = [ "impress.desktop" ];
      "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ];
      "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ];
      "application/vnd.oasis.opendocument.presentation" = [ "impress.desktop" ];
    };
  };
}
