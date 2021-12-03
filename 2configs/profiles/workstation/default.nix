{ config, lib, pkgs, ... }:

let
  desktopCfg = config.ptsd.desktop;
in
{
  imports = [
    ../../../3modules/desktop

    ./packages.nix
    ./virtualisation.nix

    ../../users/enno.nix
  ];

  # TODO: wait for https://github.com/NixOS/nixpkgs/pull/148315
  #specialisation = {
  #  i3compat.configuration = { ptsd.desktop.i3compat = true; };
  #};

  networking.firewall.allowedTCPPorts = [ 80 135 443 445 4443 4444 4445 8000 8001 9000 ]; # ports for pentesting

  environment.pathsToLink = [ "/share/nmap" ];

  # for BloodHound
  services.neo4j = {
    enable = true;
  };

  ptsd.neovim.package = pkgs.ptsd-neovim-full;

  environment.variables = {
    GOPATH = "/home/enno/go";
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  nix.trustedUsers = [ "root" "enno" ];

  security.pam.services.lightdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  i18n = {
    defaultLocale = "en_IE.UTF-8";
    extraLocaleSettings.LC_TIME = "en_DK.UTF-8"; # ISO 8601 dates
    supportedLocales = [ "en_IE.UTF-8/UTF-8" "en_DK.UTF-8/UTF-8" ];
  };

  virtualisation.spiceUSBRedirection.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  programs.steam.enable = true;

  nixpkgs.config = {
    packageOverrides = pkgs: {
      steam = pkgs.steam.override {
        extraPkgs = pkgs: [
          pkgs.openssl_1_0_2 # velocidrone
        ];
      };
    };

    permittedInsecurePackages = [
      "openssl-1.0.2u" # epsxe
    ];
  };


  home-manager.users.mainUser = { config, nixosConfig, pkgs, ... }:
    {
      imports = [
        ../../home/chromium.nix
        ../../home/fish.nix
        ../../home/git.nix
        ../../home/gpg.nix
        ../../home/mpv.nix
        ../../home/tmux.nix
        ../../home/vscodium.nix
      ];

      ptsd.firefox = {
        enable = true;
      };

      home.stateVersion = lib.mkDefault "20.09";

      programs.zathura = {
        enable = true;
        extraConfig =
          let
            cmd = desktopCfg.term.execFloating "${pkgs.file-renamer} \"%\"" "";
          in
          ''
            map <C-o> exec '${cmd}'
          '';
      };

      ptsd.pcmanfm = {
        enable = true;
        term = desktopCfg.term.binary;

        actions = {
          pdfconcat = {
            title = "Concat PDF files";
            title_de = "PDF-Dateien aneinanderhängen";
            mimetypes = [ "application/pdf" ];
            cmd = "${pkgs.alacritty}/bin/alacritty --hold -e ${pkgs.pdfconcat} %F";
            # #"${script} %F";
          };

          pdfduplex = {
            title = "Convert A & B PDF to Duplex-PDF";
            title_de = "Konvertiere A & B PDF zu Duplex-PDF";
            mimetypes = [ "application/pdf" ];
            cmd = "${pkgs.pdfduplex}/bin/pdfduplex %F";
            selectionCount = 2;
          };
        };

        thumbnailers = {
          imagemagick = {
            mimetypes = [ "application/pdf" "application/x-pdf" "image/pdf" ];
            # imagemagickBig needed because of ghostscript dependency
            cmd = ''${pkgs.imagemagickBig}/bin/convert %i[0] -background "#FFFFFF" -flatten -thumbnail %s %o'';
          };
        };
      };

      home.sessionVariables = {
        NNN_PLUG = "i:nobbofin-insert";
      };

      home.file.".config/nnn/plugins/nobbofin-insert".source = "${pkgs.ptsd-python3.pkgs.nobbofin}/bin/nobbofin-insert";

      # TODO: wait for https://github.com/vlaci/nix-doom-emacs/pull/396
      # programs.doom-emacs = {
      #   enable = true;
      #   doomPrivateDir = ../../../src/doom.d;
      # };
    };

  ptsd.desktop.keybindings = {
    "XF86Calculator" = "exec ${desktopCfg.term.execFloating "${pkgs.ptsd-py3env}/bin/ipython" ""}";
  };

  services.gvfs.enable = true; # allow smb:// mounts in pcmanfm

  # increase user watches for synchting, see
  # https://docs.syncthing.net/users/faq.html#inotify-limits
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 204800;
}
