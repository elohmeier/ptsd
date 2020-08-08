{ pkgs, ... }:
{
  imports = [ ];

  services.xserver = {
    enable = true;

    layout = "de";

    libinput = {
      enable = true;
      clickMethod = "clickfinger";
      naturalScrolling = true;
    };

    displayManager.defaultSession = "home-manager";

    desktopManager = {
      xterm.enable = false;

      session = [
        {
          name = "home-manager";
          start = ''
            ${pkgs.runtimeShell} $HOME/.xsession &
            waitPID=$!
          '';
        }
      ];
    };
  };

  programs.dconf.enable = true;

  programs.xss-lock =
    {
      enable = true;
      lockerCommand = "${pkgs.nwlock}/bin/nwlock";
      extraOptions = [
        "-n"
        "${pkgs.nwlock}/libexec/xsecurelock/dimmer" # nwlock package wraps custom xsecurelock
        "-l" # make sure not to allow machine suspend before the screen saver is active
      ];
    };
}
