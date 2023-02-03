{ config, lib, pkgs, ... }:

with lib;
{
  programs.fish = {
    enable = true;
    useBabelfish = true;

    shellAliases = {
      gaapf = "git add . && git commit --amend --no-edit && git push --force";
      gapf = "git commit --amend --no-edit && git push --force";
      grep = "grep --color";
      nr = "nixos-rebuild --use-remote-sudo --flake \"/home/enno/repos/ptsd/.#$hostname\"";
      ping6 = "ping -6";
      telnet = "screen //telnet";

      # useful to just apply config changes w/o updating packages, e.g. on the go
      #nrx = "nixos-rebuild --use-remote-sudo --flake \"/home/enno/repos/ptsd/.#$hostname\" --override-input nixpkgs github:NixOS/nixpkgs/${config.system.nixos.revision}";
    };

    shellAbbrs = {
      "cd.." = "cd ..";
      vi = "vim";

      # git
      "ga." = "git add .";
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gd = "git diff";
      gf = "git fetch";
      gl = "git log";
      gp = "git pull";
      gpp = "git push";
      gs = "git status";

      # systemd
      ctl = "systemctl";
      dn = "systemctl stop";
      jtl = "journalctl";
      st = "systemctl status";
      un = "systemctl --user stop";
      up = "systemctl start";
      ut = "systemctl --user start";
      utl = "systemctl --user";
    };

    interactiveShellInit = ''
      set -U fish_greeting
      source ${../4scripts/iterm2-integration.fish}
      fzf_configure_bindings --directory=\ct
    '' + optionalString (!config.services.qemuGuest.enable) ''
      if test -L /nix/var/nix/profiles/system
        set booted (readlink /run/booted-system/{initrd,kernel,kernel-modules})
        set built (readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})
        if test "$booted" != "$built"
          echo "please reboot"
        end
      end
    '' + ''
      function posix-source
        for i in (cat $argv)
          set arr (echo $i |tr = \n)
            set -gx $arr[1] $arr[2]
        end
      end

      ${pkgs.zoxide}/bin/zoxide init fish | source

      # show warning if $HOME is subfolder on a tmpfs mounted disk
      if test (stat -f -c %T $HOME) = tmpfs
        echo "WARNING: $HOME is on a tmpfs mounted disk"
      end
    '';
  };

  environment.systemPackages = with pkgs; mkIf config.programs.fish.enable [
    fishPlugins.fzf-fish
    fzf-no-fish
    zoxide
  ];
}
