{ config, lib, pkgs, ... }:
let
  desktopSecrets = import <secrets-shared/desktop.nix>;
in
{
  xsession.enable = true;

  imports = [
    <ptsd/3modules/home>
    #<ptsd/2configs/home/git-alarm.nix> # TODO: Port to nwi3status
  ];

  services.screen-locker = {
    enable = true;
    lockCmd = lib.mkDefault "${pkgs.i3lock}/bin/i3lock";
    # lockCmd = "${pkgs.nwlock}/bin/nwlock";
    # xssLockExtraOptions = [
    #   "-n"
    #   "${pkgs.nwlock}/libexec/xsecurelock/dimmer" # nwlock package wraps custom xsecurelock
    #   "-l" # make sure not to allow machine suspend before the screen saver is active
    # ];
  };

  systemd.user.services.flameshot = {
    Unit = {
      Description = "Screenshot Tool";
    };

    Service = {
      ExecStart = "${pkgs.flameshot}/bin/flameshot";
      RestartSec = 3;
      Restart = "on-failure";
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    config.packageOverrides = import ../../5pkgs pkgs;
  };

  ptsd.i3 = {
    enable = true;
    screenshotCommand = "exec ${pkgs.flameshot}/bin/flameshot gui";
  };

  ptsd.nwi3status = {
    enable = true;
    openweathermapApiKey = desktopSecrets.openweathermapApiKey;
  };

  ptsd.pcmanfm.enable = true;

  home = {
    file.".mozilla/native-messaging-hosts/passff.json".source = "${pkgs.passff-host}/share/passff-host/passff.json";
    keyboard = {
      layout = "de";
      variant = "nodeadkeys";
    };
    packages = with pkgs;
      [
        xorg.xev
        xorg.xhost
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
        flameshot
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
