{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    ./users/enno.nix
  ];

  #environment.systemPackages = [ (pkgs.writeShellScriptBin "activate-da-home-again" ''${config.home-manager.users.mainUser.home.activationPackage}/activate'') ];

  sound.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    pamixer
    playerctl
    qjackctl
    config.hardware.pulseaudio.package
    pavucontrol
    jack2
  ];

  programs.sway.enable = true;

  nix.gc.automatic = false;

  networking.firewall.allowedTCPPorts = [ 80 135 443 445 4443 4444 4445 8000 8001 9000 ]; # ports for pentesting
  networking.firewall.allowedUDPPorts = [ 24727 ]; # ausweisapp2

  environment.variables = {
    GOPATH = "/home/enno/go";
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  nix.trustedUsers = [ "root" "enno" ];

  # security.pam.services.lightdm.enableGnomeKeyring = true; # needed?
  services.gnome.gnome-keyring.enable = mkDefault true;

  i18n = {
    defaultLocale = "en_IE.UTF-8";
    extraLocaleSettings.LC_TIME = "en_DK.UTF-8"; # ISO 8601 dates
    supportedLocales = [ "en_IE.UTF-8/UTF-8" "en_DK.UTF-8/UTF-8" ];
  };

  virtualisation.spiceUSBRedirection.enable = mkDefault (pkgs.stdenv.hostPlatform.system != "aarch64-linux");

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = pkgs.stdenv.hostPlatform.system != "aarch64-linux";
  };

  #programs.steam.enable = pkgs.stdenv.hostPlatform.system != "aarch64-linux";

  nixpkgs.config = {
    packageOverrides = pkgs: {
      steam = pkgs.steam.override {
        extraPkgs = pkgs: [
          #pkgs.openssl_1_0_2 # velocidrone
        ];
      };
    };

    permittedInsecurePackages = [
      "openssl-1.0.2u" # epsxe
    ];
  };

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  #home-manager.users.mainUser = { config, nixosConfig, pkgs, ... }:
  #  {
  #    nixpkgs.config.packageOverrides = pkgs: {
  #      glibcLocales = nixosConfig.i18n.glibcLocales;
  #    };

  #    imports = [
  #      ./home/chromium.nix
  #      ./home/firefox.nix
  #      ./home/fish.nix
  #      ./home/fonts.nix
  #      ./home/git.nix
  #      ./home/gpg.nix
  #      ./home/mpv.nix
  #      ./home/neovim.nix
  #      ./home/packages.nix
  #      ./home/ssh.nix
  #      ./home/tmux.nix
  #      ./home/vscodium.nix
  #    ];

  #    programs.direnv.enable = true;
  #    programs.direnv.nix-direnv.enable = true;

  #    home.stateVersion = lib.mkDefault "20.09";

  #    programs.zathura = {
  #      enable = true;
  #      extraConfig =
  #        let
  #          file-renamer = pkgs.writers.writePython3 "file-renamer" { } ''
  #            import argparse
  #            import readline
  #            from pathlib import Path


  #            def rlinput(prompt, prefill=""):
  #                readline.set_startup_hook(lambda: readline.insert_text(prefill))
  #                try:
  #                    return input(prompt)
  #                finally:
  #                    readline.set_startup_hook()


  #            def main():
  #                parser = argparse.ArgumentParser()
  #                parser.add_argument("filename")
  #                args = parser.parse_args()
  #                f = Path(args.filename)
  #                if not f.exists():
  #                    raise FileNotFoundError(f)

  #                new_f = f.parent / rlinput("filename: ", f.name)
  #                f.rename(new_f)


  #            if __name__ == "__main__":
  #                main()
  #          '';
  #          cmd = desktopCfg.term.execFloating "${file-renamer} \"%\"" "";
  #        in
  #        ''
  #          map <C-o> exec '${cmd}'
  #        '';
  #    };

  #    ptsd.pcmanfm = {
  #      enable = true;
  #      term = desktopCfg.term.binary;

  #      actions = {
  #        pdfconcat = {
  #          title = "Concat PDF files";
  #          title_de = "PDF-Dateien aneinanderhängen";
  #          mimetypes = [ "application/pdf" ];
  #          cmd = "${pkgs.alacritty}/bin/alacritty --hold -e ${pkgs.pdfconcat}/bin/pdfconcat %F";
  #          # #"${script} %F";
  #        };

  #        pdfduplex = {
  #          title = "Convert A & B PDF to Duplex-PDF";
  #          title_de = "Konvertiere A & B PDF zu Duplex-PDF";
  #          mimetypes = [ "application/pdf" ];
  #          cmd = "${pkgs.pdfduplex}/bin/pdfduplex %F";
  #          selectionCount = 2;
  #        };
  #      };

  #      thumbnailers = {
  #        imagemagick = {
  #          mimetypes = [ "application/pdf" "application/x-pdf" "image/pdf" ];
  #          # imagemagickBig needed because of ghostscript dependency
  #          cmd = ''${pkgs.imagemagickBig}/bin/convert %i[0] -background "#FFFFFF" -flatten -thumbnail %s %o'';
  #        };
  #      };
  #    };

  #    home.sessionVariables = {
  #      NNN_PLUG = "i:assign-transaction;j:assign-transaction-prevyear;p:preview-tui;o:preview-sway;f:fzcd;a:autojump;c:pdfconcat;d:pdfduplex;";
  #    };
  #  };

  #ptsd.desktop.keybindings = {
  #  #"XF86Calculator" = "exec ${desktopCfg.term.execFloating "${pkgs.ptsd-py3env}/bin/ipython" ""}";
  #  "${desktopCfg.modifier}+Shift+c" = ''exec ${pkgs.grim}/bin/grim -t png -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.ptsd-tesseract}/bin/tesseract stdin stdout | ${pkgs.wl-clipboard}/bin/wl-copy -n'';
  #};

  services.gvfs.enable = mkDefault true; # allow smb:// mounts in pcmanfm

  # increase user watches for synchting, see
  # https://docs.syncthing.net/users/faq.html#inotify-limits
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 204800;

  programs.screen.screenrc = ''
    defscrollback 100000
  '';
}
