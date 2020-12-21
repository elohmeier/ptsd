{ pkgs, ... }:
{
  services.xserver = {
    enable = true;

    layout = "de";

    libinput = {
      enable = true;
      clickMethod = "clickfinger";
      naturalScrolling = true;
    };

    # displayManager.defaultSession = "home-manager";

    # desktopManager = {
    #   session = [
    #     {
    #       name = "home-manager";
    #       start = ''
    #         ${pkgs.runtimeShell} $HOME/.xsession &
    #         waitPID=$!
    #       '';
    #     }
    #   ];
    # };
  };

  environment.systemPackages =
    [ pkgs.libinput ];
}
