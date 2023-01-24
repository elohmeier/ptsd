{ config, pkgs }:
[{
  mode = "dock";
  hiddenState = "hide";
  position = "bottom";
  workspaceButtons = true;
  workspaceNumbers = true;
  statusCommand = "${pkgs.i3status}/bin/i3status";
  fonts = {
    names = [ "SauceCodePro Nerd Font" ];
    size = 10.0;
  };
  trayOutput = "primary";

  colors = with config.ptsd.style.colorsHex; {

    background = base00;
    separator = base01;
    statusline = base04;

    focusedWorkspace = {
      border = base05;
      background = base0D;
      text = base00;
    };

    activeWorkspace = {
      border = base05;
      background = base03;
      text = base00;
    };

    inactiveWorkspace = {
      border = base03;
      background = base01;
      text = base05;
    };

    urgentWorkspace = {
      border = base08;
      background = base08;
      text = base00;
    };

    bindingMode = {
      border = base00;
      background = base0A;
      text = base00;
    };
  };
}]
