{ pkgs, ... }:

let
  term = rec {
    package = pkgs.foot;
    binary = "${pkgs.foot}/bin/footclient"; # requires foot-server.service
    exec = prog: dir: "${binary}${if dir != "" then " --working-directory=\"${dir}\"" else ""}${if prog != "" then " ${prog}" else ""}";
    execFloating = prog: dir: "${binary} --app-id=term.floating${if dir != "" then " --working-directory=\"${dir}\"" else ""}${if prog != "" then " ${prog}" else ""}";
  };
in
{
  imports = [
    ./packages.nix
    ./virtualisation.nix

    ../../users/enno.nix
  ];

  environment.variables = {
    GOPATH = "/home/enno/go";
  };

  nix.trustedUsers = [ "root" "enno" ];

  security.pam.services.lightdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;


  virtualisation.spiceUSBRedirection.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  programs.steam.enable = true;


  nixpkgs.config = {
    permittedInsecurePackages = [
      "openssl-1.0.2u" # epsxe
    ];
  };


  home-manager.users.mainUser = { config, nixosConfig, pkgs, ... }:
    {
      imports = [
        ../../home/chromium.nix
        ../../home/firefox.nix
        ../../home/fish.nix
        ../../home/gpg.nix
        ../../home/neovim.nix
        ../../home/tmux.nix
        ../../home/vscodium.nix
      ];

      programs.zathura = {
        enable = true;
        extraConfig =
          let
            cmd = term.execFloating "${pkgs.file-renamer} \"%\"" "";
          in
          ''
            map <C-o> exec '${cmd}'
          '';
      };

      ptsd.pcmanfm = {
        enable = true;
        term = term.binary;

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

      wayland.windowManager.sway.config.keybindings = {

        "${nixosConfig.ptsd.desktop.modifier}+e" = "exec pcmanfm";
        #"${cfg.modifier}+e" ="exec pcmanfm \"`${cwdCmd}`\"";

        "XF86Calculator" = "exec ${term.execFloating "${pkgs.ptsd-py3env}/bin/ipython" ""}";
      };

      home.sessionVariables = {
        NNN_PLUG = "i:nobbofin-insert";
      };

      home.file.".config/nnn/plugins/nobbofin-insert".source = "${pkgs.ptsd-python3.pkgs.nobbofin}/bin/nobbofin-insert";
    };

  services.gvfs.enable = true; # allow smb:// mounts in pcmanfm

  # increase user watches for synchting, see
  # https://docs.syncthing.net/users/faq.html#inotify-limits
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 204800;
}
