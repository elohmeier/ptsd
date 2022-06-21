{ config, lib, pkgs, ... }:

with lib;
{
  programs.fish = {
    enable = true;
    useBabelfish = true;

    shellAliases = {
      gapf = "git commit --amend --no-edit && git push --force";
      gaapf = "git add . && git commit --amend --no-edit && git push --force";
      grep = "grep --color";
      ping6 = "ping -6";
      telnet = "screen //telnet";
      nr = "nixos-rebuild --use-remote-sudo --flake \"/home/enno/repos/ptsd/.#$hostname\"";

      # useful to just apply config changes w/o updating packages, e.g. on the go
      nrx = "nixos-rebuild --use-remote-sudo --flake \"/home/enno/repos/ptsd/.#$hostname\" --override-input nixpkgs github:NixOS/nixpkgs/${config.system.nixos.revision}";

      vim = "nvim";
      vi = "nvim";
    };

    shellAbbrs = {
      "cd.." = "cd ..";
      vi = "vim";

      # git
      ga = "git add";
      "ga." = "git add .";
      gc = "git commit";
      gco = "git checkout";
      gd = "git diff";
      gf = "git fetch";
      gl = "git log";
      gs = "git status";
      gp = "git pull";
      gpp = "git push";

      # systemd
      ctl = "systemctl";
      utl = "systemctl --user";
      jtl = "journalctl";
      ut = "systemctl --user start";
      un = "systemctl --user stop";
      up = "systemctl start";
      dn = "systemctl stop";
    };

    interactiveShellInit = ''
      set -U fish_greeting
    '' + optionalString (!config.services.qemuGuest.enable) ''
      set booted (readlink /run/booted-system/{initrd,kernel,kernel-modules})
      set built (readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})
      if test "$booted" != "$built"
        echo "please reboot"
      end
    '' + ''
      function posix-source
        for i in (cat $argv)
          set arr (echo $i |tr = \n)
            set -gx $arr[1] $arr[2]
        end
      end

      ${pkgs.zoxide}/bin/zoxide init fish | source
    '';
  };

  environment.systemPackages = with pkgs; mkIf config.programs.fish.enable [
    fishPlugins.fzf-fish
    fzf
    zoxide
  ];
}
