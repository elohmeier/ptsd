{ config, lib, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };
  users.users.root.password = "nixos";
  users.users.enno = {
    password = "nixos";
    isNormalUser = true;
  };
  services.getty.autologinUser = "enno";
  environment.systemPackages = with pkgs; [ foot.terminfo htop firefox ];
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  programs.bash.loginShellInit = ''
    if [ "$(tty)" = "/dev/tty1" ]; then
      exec ${pkgs.systemd}/bin/systemd-cat --identifier=sway ${pkgs.sway}/bin/sway
    fi
  '';
  environment.variables.MOZ_USE_XINPUT2 = "1";
}
