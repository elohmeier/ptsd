{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.desktop;

  writeNu = pkgs.writers.makeScriptWriter { interpreter = "${pkgs.nushell}/bin/nu"; };

  exit_mode = "exit: [l]ogout, [r]eboot, reboot-[w]indows, [s]hutdown, s[u]spend-then-hibernate, [h]ibernate, sus[p]end";

  themeConfigs = rec {
    dark = {

      font = {
        sans = "Iosevka Sans";
        mono = "SauceCode Pro";
        packages = with pkgs; [ ];
      };
    };

    light = {
      nnn_fcolors = "c1e2151600603ff7c6d6abc4";
    };

    solarized_dark = {
      nnn_fcolors = dark.nnn_fcolors;
      bg = "#002b36";
      fg = "#839496";
      contrast = "#073642";
    };

    solarized_light = {
      nnn_fcolors = light.nnn_fcolors;
      bg = "#fdf6e3";
      fg = "#586e75";
      contrast = "#eee8d5";
    };
  };

  term = rec {
    package = pkgs.foot;
    binary = "${pkgs.foot}/bin/footclient"; # requires foot-server.service
    exec = prog: dir: "${binary}${if dir != "" then " --working-directory=\"${dir}\"" else ""}${if prog != "" then " ${prog}" else ""}";
    execFloating = prog: dir: "${binary} --app-id=term.floating${if dir != "" then " --working-directory=\"${dir}\"" else ""}${if prog != "" then " ${prog}" else ""}";
  };

  theme = themeConfigs.${cfg.themeConfig};

  lockCmd =
    if cfg.lockImage != "" then ''${pkgs.swaylock}/bin/swaylock --image "${cfg.lockImage}" --scaling center --color 000000 -f''
    else "${pkgs.swaylock}/bin/swaylock --color 000000 -f";

  cwdCmd = "${pkgs.swaycwd}/bin/swaycwd";

  keybindings =
    {
      "${cfg.modifier}+Return" = "exec ${term.exec "" ""}";
      "${cfg.modifier}+Shift+q" = "kill";
      "${cfg.modifier}+d" = "exec ${pkgs.bemenu}/bin/bemenu-run ${cfg.bemenuArgs} --list 10 --prompt 'Run:'";

      #"${cfg.modifier}+d" = "exec ${pkgs.dmenu}/bin/dmenu_path | ${pkgs.dmenu}/bin/dmenu -p \"Run:\" -l 10 | ${pkgs.findutils}/bin/xargs ${pkgs.sway}/bin/swaymsg exec";

      # change focus
      "${cfg.modifier}+h" = "focus left";
      "${cfg.modifier}+j" = "focus down";
      "${cfg.modifier}+k" = "focus up";
      "${cfg.modifier}+l" = "focus right";
      "${cfg.modifier}+Left" = "focus left";
      "${cfg.modifier}+Down" = "focus down";
      "${cfg.modifier}+Up" = "focus up";
      "${cfg.modifier}+Right" = "focus right";
      "${cfg.modifier}+g" = "focus next";
      "${cfg.modifier}+Shift+g" = "focus prev";

      "${cfg.modifier}+Mod1+h" = "workspace prev_on_output";
      "${cfg.modifier}+Mod1+l" = "workspace next_on_output";
      "${cfg.modifier}+Mod1+Left" = "workspace prev_on_output";
      "${cfg.modifier}+Mod1+Right" = "workspace next_on_output";

      # move focused window
      "${cfg.modifier}+Shift+h" = "move left";
      "${cfg.modifier}+Shift+j" = "move down";
      "${cfg.modifier}+Shift+k" = "move up";
      "${cfg.modifier}+Shift+l" = "move right";
      "${cfg.modifier}+Shift+Left" = "move left";
      "${cfg.modifier}+Shift+Down" = "move down";
      "${cfg.modifier}+Shift+Up" = "move up";
      "${cfg.modifier}+Shift+Right" = "move right";

      "${cfg.modifier}+f" = "fullscreen toggle";

      # change layouts with mod+,.-
      "${cfg.modifier}+comma" = "layout stacking";
      "${cfg.modifier}+period" = "layout tabbed";
      "${cfg.modifier}+minus" = "layout toggle split";

      # toggle floating
      "${cfg.modifier}+Shift+space" = "floating toggle";

      # swap focus between tiling and floating windows
      "${cfg.modifier}+space" = "focus mode_toggle";

      # move focus to parent container
      "${cfg.modifier}+a" = "focus parent";

      # move windows in and out of the scratchpad
      "${cfg.modifier}+Shift+t" = "move scratchpad";
      "${cfg.modifier}+t" = "scratchpad show";

      # cycle through border styles
      "${cfg.modifier}+b" = "border toggle";

      # "Space-Hack" to fix the ordering in the generated config file
      # This prevents that i3 uses this order: 10, 1, 2, ...
      " ${cfg.modifier}+1" = "workspace number 1";
      " ${cfg.modifier}+2" = "workspace number 2";
      " ${cfg.modifier}+3" = "workspace number 3";
      " ${cfg.modifier}+4" = "workspace number 4";
      " ${cfg.modifier}+5" = "workspace number 5";
      " ${cfg.modifier}+6" = "workspace number 6";
      " ${cfg.modifier}+7" = "workspace number 7";
      " ${cfg.modifier}+8" = "workspace number 8";
      " ${cfg.modifier}+9" = "workspace number 9";
      "${cfg.modifier}+0" = "workspace number 10";

      "${cfg.modifier}+Shift+1" = "move container to workspace number 1";
      "${cfg.modifier}+Shift+2" = "move container to workspace number 2";
      "${cfg.modifier}+Shift+3" = "move container to workspace number 3";
      "${cfg.modifier}+Shift+4" = "move container to workspace number 4";
      "${cfg.modifier}+Shift+5" = "move container to workspace number 5";
      "${cfg.modifier}+Shift+6" = "move container to workspace number 6";
      "${cfg.modifier}+Shift+7" = "move container to workspace number 7";
      "${cfg.modifier}+Shift+8" = "move container to workspace number 8";
      "${cfg.modifier}+Shift+9" = "move container to workspace number 9";
      "${cfg.modifier}+Shift+0" = "move container to workspace number 10";

      "${cfg.modifier}+Control+Mod1+h" = "move container to workspace prev_on_output";
      "${cfg.modifier}+Control+Mod1+l" = "move container to workspace next_on_output";
      "${cfg.modifier}+Control+Mod1+Left" = "move container to workspace prev_on_output";
      "${cfg.modifier}+Control+Mod1+Right" = "move container to workspace next_on_output";

      "${cfg.modifier}+Shift+r" = "reload";

      "${cfg.modifier}+r" = "mode \"resize\"";
      "${cfg.modifier}+w" = "mode \"window\"";

      "${cfg.modifier}+Shift+Delete" = "exec ${lockCmd}";
      "${cfg.modifier}+Shift+Return" = "exec ${term.exec "" "`${cwdCmd}`"}";
      #"${cfg.modifier}+Shift+c" = "exec codium \"`${cwdCmd}`\"";
      "${cfg.modifier}+Shift+c" = ''exec ${pkgs.grim}/bin/grim -t png -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.tesseract}/bin/tesseract stdin stdout | ${pkgs.wl-clipboard}/bin/wl-copy -n'';


      "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 10%+ | sed -En 's/.*\\(([0-9]+)%\\).*/\\1/p' > $WOBSOCK";
      "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 10%- | sed -En 's/.*\\(([0-9]+)%\\).*/\\1/p' > $WOBSOCK";

      "XF86AudioMute" = mkIf (cfg.audio.enable && cfg.primarySpeaker != null)
        "exec ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --toggle-mute && (${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --get-mute && echo 0 > $WOBSOCK ) || ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --get-volume > $WOBSOCK";
      "XF86AudioLowerVolume" = mkIf (cfg.audio.enable && cfg.primarySpeaker != null)
        "exec ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --unmute --decrease 5 && ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --get-volume > $WOBSOCK";
      "XF86AudioRaiseVolume" = mkIf (cfg.audio.enable && cfg.primarySpeaker != null)
        "exec ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --unmute --increase 5 && ${pkgs.pamixer}/bin/pamixer --sink ${cfg.primarySpeaker} --get-volume > $WOBSOCK";
      "XF86AudioMicMute" = mkIf (cfg.audio.enable && cfg.primaryMicrophone != null) "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute ${cfg.primaryMicrophone} toggle";

      "XF86Calculator" = lib.mkDefault "exec ${term.execFloating "${pkgs.bc}/bin/bc -l" ""}";
      "XF86HomePage" = "exec firefox";
      "XF86Search" = "exec firefox";
      "XF86Mail" = "exec evolution";
      "XF86Launch5" = "exec spotify"; # Label: 1
      "XF86Launch8" = mkIf cfg.audio.enable "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume alsa_output.usb-LG_Electronics_Inc._USB_Audio-00.analog-stereo -5%"; # Label: 4
      "XF86Launch9" = mkIf cfg.audio.enable "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume alsa_output.usb-LG_Electronics_Inc._USB_Audio-00.analog-stereo +5%"; # Label: 5

      "XF86AudioPlay" = mkIf cfg.audio.enable "exec ${pkgs.playerctl}/bin/playerctl play-pause";
      "${cfg.modifier}+p" = mkIf cfg.audio.enable "exec ${pkgs.playerctl}/bin/playerctl play-pause";
      "XF86AudioStop" = mkIf cfg.audio.enable "exec ${pkgs.playerctl}/bin/playerctl stop";
      "XF86AudioNext" = mkIf cfg.audio.enable "exec ${pkgs.playerctl}/bin/playerctl next";
      "${cfg.modifier}+n" = mkIf cfg.audio.enable "exec ${pkgs.playerctl}/bin/playerctl next";
      "XF86AudioPrev" = mkIf cfg.audio.enable "exec ${pkgs.playerctl}/bin/playerctl previous";
      "${cfg.modifier}+Shift+n" = mkIf cfg.audio.enable "exec ${pkgs.playerctl}/bin/playerctl previous";

      "${cfg.modifier}+Shift+u" = "resize shrink width 20 px or 20 ppt";
      "${cfg.modifier}+Shift+i" = "resize shrink height 20 px or 20 ppt";
      "${cfg.modifier}+Shift+o" = "resize grow height 20 px or 20 ppt";
      "${cfg.modifier}+Shift+p" = "resize grow width 20 px or 20 ppt";

      "${cfg.modifier}+Home" = "workspace number 1";
      "${cfg.modifier}+Prior" = "workspace prev";
      "${cfg.modifier}+Next" = "workspace next";
      "${cfg.modifier}+End" = "workspace number 10";
      "${cfg.modifier}+Tab" = "workspace back_and_forth";

      # not working
      #"${cfg.modifier}+p" = ''[instance="scratch-term"] scratchpad show'';

      "${cfg.modifier}+Shift+e" = ''mode "${exit_mode}"'';

      #"${cfg.modifier}+numbersign" = "split horizontal;; exec ${term.exec "" "`${cwdCmd}`"}";
      #"${cfg.modifier}+minus" = "split vertical;; exec ${term.exec "" "`${cwdCmd}`"}";

      #"${cfg.modifier}+a" = ''[class="Firefox"] scratchpad show'';
      #"${cfg.modifier}+b" = ''[class="Firefox"] scratchpad show'';

      # screenshots
      "Print" = ''exec ${pkgs.grim}/bin/grim -t png ~/Pocket/Screenshots/$(${pkgs.coreutils}/bin/date +"%Y-%m-%d_%H:%M:%S.png")'';
      "${cfg.modifier}+Ctrl+Shift+4" =
        #''exec ${pkgs.grim}/bin/grim -t png -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png''
        ''exec ${pkgs.grim}/bin/grim -t png -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f -'';
    };

  modes = {
    "${exit_mode}" = {
      "l" = ''exec swaymsg exit; mode "default"'';
      "r" = ''exec systemctl reboot; mode "default"'';
      "w" = ''exec systemctl reboot --boot-loader-entry=auto-windows; mode "default"'';
      "s" = ''exec systemctl poweroff; mode "default"'';
      "u" = ''exec systemctl suspend-then-hibernate; mode "default"'';
      "p" = ''exec systemctl suspend; mode "default"'';
      "h" = ''exec systemctl hibernate; mode "default"'';
      "Escape" = ''mode "default"'';
      "Return" = ''mode "default"'';
    };

    resize = {
      "Left" = "resize shrink width 10 px or 10 ppt";
      "Down" = "resize grow height 10 px or 10 ppt";
      "Up" = "resize shrink height 10 px or 10 ppt";
      "Right" = "resize grow width 10 px or 10 ppt";
      "Escape" = "mode default";
      "Return" = "mode default";
      "${cfg.modifier}+r" = "mode default";
      "j" = "resize shrink width 10 px or 10 ppt";
      "k" = "resize grow height 10 px or 10 ppt";
      "l" = "resize shrink height 10 px or 10 ppt";
      "odiaeresis" = "resize grow width 10 px or 10 ppt";
    };

    # vim-style window splits and resizing after hitting mod+w
    window = {
      "s" = "split v; mode \"default\"";
      "v" = "split h; mode \"default\"";
      "Shift+comma" = "resize shrink width 10 ppt or 10 px";
      "Shift+period" = "resize grow width 10 ppt or 10 px";
      "Shift+equal" = "resize grow height 10 ppt or 10 px";
      "Shift+minus" = "resize shrink height 10 ppt or 10 px";

      # leave window mode
      "Return" = "mode \"default\"";
      "Escape" = "mode \"default\"";
    };
  };

  # to get the class of a window run `xprop WM_CLASS` and click on the window
  window_commands = [
    # not working
    #{
    #  command = ''floating enable, move to scratchpad'';
    #  criteria.instance = "scratch-term";
    #}
    #{
    #  criteria.class = "Firefox";
    #  command = "floating enable, resize set 90 ppt 90 ppt, move position center, move to scratchpad, scratchpad show";
    #}
    {
      criteria.class = ".blueman-manager-wrapped";
      command = "floating enable";
    }
    {
      criteria.class = "Pavucontrol";
      command = "floating enable";
    }
    {
      criteria.title = "Firefox — Sharing Indicator";
      command = "kill";
    }
    {
      criteria.app_id = "term.floating";
      command = "floating enable";
    }
  ];

  fonts = {
    names = [ cfg.fontSans ];
    size = cfg.fontSize;
  };

  # src: https://github.com/kaihendry/dotfiles/blob/master/bin/xdg-open
  choose-browser = pkgs.writers.writeDash "choose-browser" ''
    profile="$(\
        cat <<- EOF | ${pkgs.bemenu}/bin/bemenu ${cfg.bemenuArgs} --list 10
    Firefox
    Chromium
    Firefox-bwrap-enno
    EOF
    )"

    case "$profile" in
        "Firefox")
        echo "Firefox"
        firefox "$@"
        ;;
        "Chromium")
        chromium "$@"
        ;;
        "Firefox-bwrap-enno")
        bwrap \
            --ro-bind /nix/store /nix/store \
            --tmpfs /run \
            --ro-bind /etc/fonts /etc/fonts \
            --ro-bind /etc/machine-id /etc/machine-id \
            --ro-bind /etc/resolv.conf /etc/resolv.conf \
            --dir /run/user/"$(id -u)" \
            --ro-bind /run/current-system/sw/bin /run/current-system/sw/bin \
            --ro-bind /run/user/"$(id -u)"/pulse /run/user/"$(id -u)"/pulse \
            --ro-bind /run/user/"$(id -u)"/$WAYLAND_DISPLAY /run/user/"$(id -u)"/$WAYLAND_DISPLAY \
            --proc /proc \
            --bind ~/.mozilla ~/.mozilla \
            --bind ~/.cache/mozilla ~/.cache/mozilla \
            --bind ~/Downloads ~/Downloads \
            --unshare-all \
            --share-net \
            --hostname RESTRICTED \
            --setenv MOZ_ENABLE_WAYLAND 1 \
            --setenv PATH /run/current-system/sw/bin \
            --die-with-parent \
            --new-session \
            $(readlink $(which firefox)) "$@"
        ;;
    esac
  '';
in
{
  options = {
    ptsd.desktop = {
      enable = mkEnableOption "ptsd.desktop";
      pipewire.enable = mkOption {
        type = types.bool;
        default = true;
        description = "use pipewire instead of pulseaudio";
      };
      fontSans = mkOption {
        type = types.str;
        default = "Ioseka Sans"; # TODO: expose package, e.g. for gtk
      };
      fontMono = mkOption {
        type = types.str;
        default = "Consolas";
      };
      fontSize = mkOption {
        type = types.float;
        default = 10.0;
      };
      primaryMicrophone = mkOption {
        type = with types; nullOr str;
        description = "Pulseaudio microphone device name";
        default = "@DEFAULT_SOURCE@";
      };
      primarySpeaker = mkOption {
        type = with types; nullOr str;
        description = "Pulseaudio speaker device name";
        default = "@DEFAULT_SINK@";
      };
      themeConfig = mkOption {
        type = types.str;
        default = "dark";
      };
      trayOutput = mkOption {
        type = types.str;
        default = "primary";
        description = "Where to output tray.";
      };
      modifier = mkOption {
        type = types.str;
        default = "Mod4";
      };
      lockImage = mkOption {
        type = types.str;
        default = "";
      };
      hideCursorIdleSec = mkOption {
        type = types.int;
        default = 1;
      };
      bemenuArgs = mkOption { type = types.str; default = ""; };
      waybar.co2 = mkOption {
        type = types.bool;
        default = false;
      };
      waybar.bgColor = mkOption { type = types.str; default = "#ffffff"; };
      waybar.fgColor = mkOption { type = types.str; default = "#000000"; };
      waybar.contrastColor = mkOption { type = types.str; default = "#111111"; };
      waybar.accentColor = mkOption { type = types.str; default = "#1a1a1a"; };
      audio.enable = mkOption {
        type = types.bool;
        default = true;
      };
      nvidia.enable = mkOption { type = types.bool; default = false; };
      bluetooth.enable = mkOption {
        type = types.bool;
        default = true;
      };
      qt.enable = mkOption {
        type = types.bool;
        default = true;
      };
      numlockAuto = mkOption {
        type = types.bool;
        default = true;
      };
      defaultBrowser = mkOption {
        type = types.str;
        default = "choose-browser.desktop";
      };
      autolock.enable = mkOption {
        type = types.bool;
        default = true;
      };
      rclone.enable = mkOption {
        type = types.bool;
        default = false;
      };
      baresip = mkOption {
        default = { };
        type = types.submodule {
          options = {
            enable = mkEnableOption "baresip";
            audioPlayer = mkOption { type = types.str; default = ""; };
            audioSource = mkOption { type = types.str; default = ""; };
            audioAlert = mkOption { type = types.str; default = ""; };
            sipListen = mkOption { type = types.str; default = ""; example = "10.0.0.2:5060"; };
            netInterface = mkOption { type = types.str; default = ""; example = "nwvpn"; };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {

    ptsd.secrets.files."hass-cli.env" = mkIf cfg.waybar.co2 {
      owner = config.users.users.mainUser.name;
    };
    ptsd.secrets.files.baresip-accounts = mkIf cfg.baresip.enable {
      owner = config.users.users.mainUser.name;
    };
    ptsd.secrets.files."fraam-gdrive-backup-3b42c04ff1ec.json" = mkIf cfg.rclone.enable {
      owner = config.users.users.mainUser.name;
    };

    security.sudo.extraRules = lib.mkAfter [
      {
        users = [ config.users.users.mainUser.name ];
        commands = [
          { command = "${config.nix.package}/bin/nix-collect-garbage"; options = [ "NOPASSWD" ]; }
          { command = "${pkgs.iftop}/bin/iftop"; options = [ "NOPASSWD" ]; }
        ];
      }
    ];

    programs.browserpass.enable = true;

    # speed up networking
    boot.kernelModules = [ "tcp_bbr" ];
    boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr"; # affects both IPv4 and IPv6r

    xdg.portal = {
      enable = true;
      gtkUsePortal = true;
      extraPortals = with pkgs;[ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
    };

    boot.supportedFilesystems = [
      "exfat" # canon sd card
      "nfs"
    ];

    services.dbus.packages = [ pkgs.gcr ]; # for pinentry-gnome3 for gnupg

    security.polkit.enable = true;

    environment.variables = {
      PASSWORD_STORE_DIR = "/home/enno/repos/password-store";
      QT_STYLE_OVERRIDE = "gtk2"; # for qt5 apps (e.g. keepassxc)
      TERMINAL = term.binary;

      # Breaks all other loaders, e.g. for PNG. TODO: combine with integrated loaders.
      # IMLIB2_LOADER_PATH = "${pkgs.imlib2-heic}/imlib2/loaders";

      SDL_VIDEODRIVER = "wayland";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      _JAVA_AWT_WM_NONREPARENTING = "1";
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_TYPE = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_USE_XINPUT2 = "1";
      _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on";

    } // optionalAttrs cfg.rclone.enable {
      RCLONE_CONFIG =
        let
          fraamCfg = import ../2configs/fraam-gdrives.nix;
          genCfg = drive_name: drive_id: nameValuePair drive_name {
            type = "drive";
            client_id = "100812309064118189865";
            scope = "drive";
            service_account_file = config.ptsd.secrets.files."fraam-gdrive-backup-3b42c04ff1ec.json".path;
            impersonate = "enno.richter@fraam.de";
            team_drive = drive_id;
          };
        in
        toString (pkgs.writeText "rclone.conf" (lib.generators.toINI { } (mapAttrs' genCfg fraamCfg.drives)));
    };

    system.fsPackages = [ pkgs.ntfs3g ];
    environment.systemPackages = with pkgs; [
      bemenu
      term.package
      libinput
      libnotify
      brightnessctl
      pciutils
    ] ++ optionals cfg.audio.enable [
      pamixer
      playerctl
      cadence
      qjackctl
      config.hardware.pulseaudio.package
      pavucontrol
      pasystray
      jack2
    ];


    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

    # yubikey
    services.udev.packages = [ pkgs.libu2f-host pkgs.yubikey-personalization ];
    services.pcscd.enable = true;

    hardware.nitrokey = {
      enable = true;
    };

    users.groups.nitrokey.members = [ config.users.users.mainUser.name ];
    users.groups.keys.members = [ config.users.users.mainUser.name ];

    fonts.fonts = with pkgs; [
      cozette
      #iosevka # TODO: replace, pulls in i686-incompatible dependencies
      nerdfonts
      nwfonts
      proggyfonts
      roboto
      roboto-slab
      source-code-pro
      win10fonts
    ];

    # for betaflight-configurator firmware flashing
    # from https://github.com/betaflight/betaflight/wiki/Installing-Betaflight#platform-specific-linux
    services.udev.extraRules = ''
      # DFU (Internal bootloader for STM32 MCUs)
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0664", GROUP="dialout"
    '';

    services.upower.enable = true;

    sound.enable = true;

    programs.wireshark.enable = true;
    users.groups.wireshark.members = [ config.users.users.mainUser.name ];

    hardware = {
      bluetooth = {
        enable = cfg.bluetooth.enable;
        hsphfpd.enable = true;
        package = pkgs.bluezFull;
      };

      pulseaudio = {
        enable = cfg.audio.enable && !cfg.pipewire.enable;
        package = lib.mkDefault pkgs.pulseaudioFull; # pulseAudioFull required for bluetooth audio support
        support32Bit = true; # for Steam

        # better audio quality settings
        # from https://medium.com/@gamunu/enable-high-quality-audio-on-linux-6f16f3fe7e1f
        daemon.config = {
          default-sample-format = "float32le";
          default-sample-rate = lib.mkDefault 48000;
          alternate-sample-rate = 44100;
          default-sample-channels = 2;
          default-channel-map = "front-left,front-right";
          resample-method = "speex-float-10";
          enable-lfe-remixing = "no";
          high-priority = "yes";
          nice-level = -11;
          realtime-scheduling = "yes";
          realtime-priority = 9;
          rlimit-rtprio = 9;
        };

        extraModules = [ pkgs.pulseaudio-modules-bt ];
      };
    };

    services.blueman.enable = cfg.bluetooth.enable;

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    services.pipewire = mkIf (cfg.audio.enable && cfg.pipewire.enable) {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
      media-session = {
        enable = true;
      };
    };


    home-manager =
      {
        users.mainUser = { config, nixosConfig, pkgs, ... }:
          {

            imports = [
              ./home
            ];

            programs.mako = {
              enable = true;
            };

            systemd.user.services.wob = {
              Unit = {
                Description = "Overlay bar for Wayland";
                Documentation = "man:wob(1)";
                PartOf = [ "graphical-session.target" ];
                After = [ "graphical-session.target" ];
                ConditionEnvironment = "WAYLAND_DISPLAY";
              };

              Service = {
                StandardInput = "socket";
                ExecStart = "${pkgs.wob}/bin/wob --anchor bottom --anchor right --margin 50";
              };
              Install = { WantedBy = [ "graphical-session.target" ]; };
            };

            systemd.user.sockets.wob = {
              Socket = {
                ListenFIFO = "%t/wob.sock";
                SocketMode = "0600";
              };
              Install = { WantedBy = [ "sockets.target" ]; };
            };

            programs.foot = {
              enable = true;
              settings = {
                main = {
                  font = lib.mkDefault "SauceCodePro Nerd Font:size=${toString (cfg.fontSize - 3.0)}";
                  dpi-aware = lib.mkDefault "yes";
                };
                scrollback.lines = 50000;
              };
            };

            programs.waybar = {
              enable = true;
              settings = [
                {
                  layer = "top";
                  position = "bottom";
                  height = 21;
                  modules-left = [ "sway/workspaces" "sway/mode" ];
                  modules-center = [
                  ];
                  modules-right = (lib.optional cfg.autolock.enable "idle_inhibitor") ++ [ "custom/nobbofin-inbox" ] ++ (lib.optional cfg.waybar.co2
                    "custom/co2") ++ [
                    "disk#home"
                    "disk#nix"
                    "disk#xdg-runtime-dir"
                  ]
                    ++ optional cfg.audio.enable
                    "pulseaudio" ++ [
                    "network"
                    "network#tun0"
                    "cpu"
                    "memory"
                  ] ++ optional cfg.nvidia.enable "custom/nvidia" ++ [
                    #"backlight"
                    "battery"
                    "clock"
                    "tray"
                  ];
                  modules = {

                    idle_inhibitor = mkIf cfg.autolock.enable {
                      format = "{icon}";
                      format-icons = {
                        activated = "";
                        deactivated = "";
                      };
                    };
                    "custom/co2" = mkIf cfg.waybar.co2 {
                      format = "co2 {}ppm";
                      exec = "${pkgs.read-co2-status}/bin/read-co2-status";
                      interval = 30;
                      return-type = "json";
                    };
                    "custom/nobbofin-inbox" = {
                      format = "nbf {}";
                      exec = pkgs.writeShellScript "nobbofin-inbox" ''
                        ${pkgs.findutils}/bin/find /home/enno/repos/nobbofin/000_INBOX -type f | wc -l
                      '';
                      interval = 30;
                    };
                    "disk#home" = rec {
                      format = "h {percentage_free}%";
                      path = "/home";
                      on-click-right = term.execFloating "${pkgs.ncdu}/bin/ncdu -x ${path}" "";
                      states = {
                        warning = 15;
                        critical = 5;
                      };
                    };
                    "disk#nix" = rec {
                      format = "nix {percentage_free}%";
                      path = "/nix";
                      states = {
                        warning = 15;
                        critical = 5;
                      };
                    };
                    "disk#xdg-runtime-dir" = rec {
                      format = "xrd {percentage_free}%";
                      path = "/run/user/1000";
                      on-click-right = term.execFloating "${pkgs.ncdu}/bin/ncdu -x ${path}" "";
                      states = {
                        warning = 15;
                        critical = 5;
                      };
                    };
                    cpu = {
                      format = "{usage}% ";
                      on-click-right = term.execFloating "${pkgs.htop}/bin/htop" "";
                    };
                    memory = {
                      format = "{}% ";
                      on-click-right = term.execFloating "${pkgs.procps}/bin/watch -n1 ${pkgs.coreutils}/bin/cat /proc/meminfo" "";
                    };
                    "custom/nvidia" = mkIf cfg.nvidia.enable {
                      format = "nv {}";
                      exec = writeNu "nv-status" ''
                        nvidia-smi --query-gpu=pstate,utilization.gpu,utilization.memory,temperature.gpu --format=csv,nounits | from csv | str trim  | each { echo $"($it.pstate) ($it.' utilization.gpu [%]')%C ($it.' utilization.memory [%]')%M ($it.' temperature.gpu')C" }
                      '';
                      interval = 30;
                    };
                    battery = {
                      states = { warning = 30; critical = 15; };
                      format = "{capacity}% {icon}";
                      format-charging = "{capacity}% ";
                      format-plugged = "{capacity}% ";
                      format-alt = "{time} {icon}";
                      format-icons = [ "" "" "" "" "" ];
                    };
                    clock = {
                      format = "{:%a, %d. %b  %H:%M}";
                      on-click-right = term.execFloating "bash -c 'cal -w -y && echo press enter to exit && read'" "";
                    };
                    network = {
                      format-wifi = "{essid} ({signalStrength}%) ";
                      format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
                      format-linked = "{ifname} (No IP) ";
                      format-disconnected = "Disconnected ⚠";
                      format-alt = "{ifname}: {ipaddr}/{cidr}";
                      on-click-right = mkIf nixosConfig.networking.networkmanager.enable (term.execFloating "${pkgs.networkmanager}/bin/nmtui" "");
                    };
                    "network#tun0" = {
                      interface = "tun0";
                      format = "{ifname} {ipaddr}";
                    };
                    pulseaudio = mkIf cfg.audio.enable {
                      format = "{volume}% {icon} {format_source}";
                      format-bluetooth = "{volume}% {icon} {format_source}";
                      format-bluetooth-muted = " {icon} {format_source}";
                      format-muted = " {format_source}";
                      format-source = "{volume}% ";
                      format-source-muted = "";
                      format-icons = {
                        headphone = "";
                        hands-free = "";
                        headset = "";
                        phone = "";
                        portable = "";
                        car = "";
                        default = [ "" "" "" ];
                      };
                      on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
                    };
                    #"custom/hello-from-waybar" = {
                    #  format = "hello {}";
                    #  max-length = 40;
                    #  interval = "once";
                    #  exec = pkgs.writeShellScript "hello-from-waybar" ''
                    #    echo "from within waybar"
                    #  '';
                    #};
                  };
                }
              ];
              style =
                ''
                  * {
                      border: none;
                      border-radius: 0;
                      font-family: ${cfg.fontSans};
                      font-size: ${toString cfg.fontSize}pt;
                      min-height: 0;
                  }

                  window#waybar {
                      background-color: ${cfg.waybar.bgColor};
                      color: ${cfg.waybar.fgColor};
                      transition-property: background-color;
                      transition-duration: .5s;
                  }

                  window#waybar.hidden {
                      opacity: 0.2;
                  }
              
                  /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
                  #workspaces button {
                      padding: 0 5px;
                      background-color: transparent;
                      color: ${cfg.waybar.fgColor};
                      border-bottom: 3px solid transparent;
                  }

                  #workspaces button.focused {
                      background-color: ${cfg.waybar.contrastColor};
                      border-bottom: 1px solid ${cfg.waybar.accentColor};
                  }

                  #workspaces button.urgent {
                      background-color: ${cfg.waybar.accentColor};
                  }

                  #mode {
                      background-color: ${cfg.waybar.bgColor};
                      border-bottom: 1px solid #dc322f;
                  }

                  #clock, #battery, #cpu, #memory, #backlight, #network, #pulseaudio, #tray, #mode, #idle_inhibitor, #disk, #custom-co2 {
                      padding: 0 10px;
                      margin: 0 2px;
                      background-color: ${cfg.waybar.bgColor};
                      color: ${cfg.waybar.fgColor};
                  }
                
                  #battery.charging {
                      color: #eee8d5;
                      background-color: #859900;
                  }

                  @keyframes blink {
                      to {
                          background-color: #d33682;
                          color: #93a1a1;
                      }
                  }

                  #custom-co2.alert {
                    background-color: #dc322f;
                    color: #ffffff;
                  }

                  #battery.critical:not(.charging) {
                      background-color: #dc322f;
                      color: #93a1a1;
                      animation-name: blink;
                      animation-duration: 0.5s;
                      animation-timing-function: linear;
                      animation-iteration-count: infinite;
                      animation-direction: alternate;
                  }

                  label:focus {
                      background-color: ${cfg.waybar.contrastColor};
                  }

                  #pulseaudio.muted {
                      background-color: ${cfg.waybar.contrastColor};
                  }

                  #idle_inhibitor.activated {
                      background-color: ${cfg.waybar.contrastColor};
                  }

                '';
            };


            home = {
              keyboard = {
                layout = "de";
                variant = "nodeadkeys";
              };
            };


            xdg =
              {
                mimeApps = {
                  enable = true;

                  # verify using `xdg-mime query default <mimetype>`
                  defaultApplications = {
                    "application/pdf" = [ "zathura.desktop" ];
                    "text/plain" = [ "vim.desktop" ];
                    "text/x-script.python" = [ "vim.desktop" ];
                    "image/gif" = [ "sxiv.desktop" ];
                    "image/heic" = [ "sxiv.desktop" ];
                    "image/jpeg" = [ "sxiv.desktop" ];
                    "image/png" = [ "sxiv.desktop" ];
                    "inode/directory" = [ "pcmanfm.desktop" ];
                    "text/html" = [ cfg.defaultBrowser ];
                    "x-scheme-handler/http" = [ cfg.defaultBrowser ];
                    "x-scheme-handler/https" = [ cfg.defaultBrowser ];
                    "x-scheme-handler/about" = [ cfg.defaultBrowser ];
                    "x-scheme-handler/unknown" = [ cfg.defaultBrowser ];
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

                # force overwrite of mimeapps.list, since it will be manipulated by some desktop apps without asking
                configFile."mimeapps.list".force = true;

                dataFile = {

                  "applications/choose-browser.desktop" =
                    {
                      text = lib.generators.toINI
                        { }
                        {
                          "Desktop Entry" = {
                            Categories = "Network;WebBrowser;";
                            Name = "Choose Browser";
                            Comment = "";
                            Exec = "${choose-browser} %U";
                            Terminal = false;
                            Type = "Application";
                            MimeType = "text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp";
                            GenericName = "Web Browser";
                          };
                        };
                      onChange = "${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.xdg.dataHome}/applications/";
                    };

                  # not working
                  # "mime/application/vnd.jgraph.mxfile.xml".text = ''
                  #   <?xml version="1.0" encoding="utf-8"?>
                  #   <mime-type xmlns="http://www.freedesktop.org/standards/shared-mime-info" type="application/vnd.jgraph.mxfile">
                  #     <comment>JGraph MXFile</comment>
                  #     <glob pattern="*.drawio"/>
                  #   </mime-type>
                  # '';

                  "file-manager/actions/nobbofin_assign_fzf.desktop".text = lib.generators.toINI
                    { }
                    {
                      "Desktop Entry" = {
                        Type = "Action";
                        Name = "Assign PDF to Nobbofin Transaction";
                        "Name[de]" = "PDF Nobbofin-Transaktion zuordnen";
                        Profiles = "nobbofin_assign_fzf;";
                      };

                      "X-Action-Profile nobbofin_assign_fzf" = {
                        MimeTypes = "application/pdf";
                        Exec = term.execFloating "/home/enno/repos/nobbofin/assign-doc-fzf.py %f" "";
                      };
                    };

                  "file-manager/actions/sylpheed_attach.desktop".text = lib.generators.toINI
                    { }
                    {
                      "Desktop Entry" = {
                        Type = "Action";
                        Name = "Send via E-Mail (Sylpheed)";
                        "Name[de]" = "Per E-Mail senden (Sylpheed)";
                        Profiles = "sylpheed_attach;";
                        Icon = "sylpheed";
                      };

                      "X-Action-Profile sylpheed_attach" = {
                        MimeTypes = "all/allfiles";
                        Exec = "sylpheed --attach %F";
                      };
                    };

                  "file-manager/actions/xdg_attach.desktop".text = lib.generators.toINI
                    { }
                    {
                      "Desktop Entry" = {
                        Type = "Action";
                        Name = "Send via E-Mail (xdg-email)";
                        "Name[de]" = "Per E-Mail senden (xdg-email)";
                        Profiles = "xdg_attach;";
                        Icon = "evolution";
                      };

                      "X-Action-Profile xdg_attach" = {
                        MimeTypes = "all/allfiles";
                        Exec = "xdg-email --attach %F";
                      };
                    };

                  "file-manager/actions/print-lp.desktop".text = lib.generators.toINI
                    { }
                    {
                      "Desktop Entry" = {
                        Type = "Action";
                        Name = "Print (lp)";
                        "Name[de]" = "Drucken (lp)";
                        Profiles = "print;";
                      };

                      "X-Action-Profile print" = {
                        MimeTypes = "application/pdf";
                        Exec = "${pkgs.cups}/bin/lp %F";
                      };
                    };

                  "file-manager/actions/pdf2svg.desktop".text = lib.generators.toINI
                    { }
                    {
                      "Desktop Entry" = {
                        Type = "Action";
                        Name = "Convert PDF to SVG";
                        "Name[de]" = "Konvertiere PDF zu SVG";
                        Profiles = "pdf2svg;";
                      };

                      "X-Action-Profile pdf2svg" = {
                        MimeTypes = "application/pdf";
                        Exec = "pdf2svg %f %f.svg";
                      };
                    };

                  "applications/fava.desktop" = {
                    text = lib.generators.toINI
                      { }
                      {
                        "Desktop Entry" = {
                          Name = "Fava";
                          TryExec = "fava";
                          Exec = "fava %F";
                          Terminal = true;
                          Type = "Application";
                          StartupNotify = false;
                          MimeType = "text/plain;";
                        };
                      };
                    onChange = "${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.xdg.dataHome}/applications/";
                  };

                  "applications/vim.desktop" = {
                    text = lib.generators.toINI
                      { }
                      {
                        "Desktop Entry" = {
                          Name = "Vim";
                          Comment = "Edit text files in a console using Vim";
                          TryExec = "vim";
                          Exec = term.exec "vim %F" "";
                          Terminal = false;
                          Type = "Application";
                          Icon = "${pkgs.tango-icon-theme}/share/icons/Tango/scalable/apps/text-editor.svg";
                          Categories = "Application;Utility;TextEditor;";
                          StartupNotify = false;
                          MimeType = "text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;";
                        };
                      };
                    onChange = "${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.xdg.dataHome}/applications/";
                  };
                };
              };

            home.file = {
              ".mozilla/native-messaging-hosts/passff.json".source = "${pkgs.passff-host}/share/passff-host/passff.json";
            } // optionalAttrs cfg.baresip.enable {
              ".baresip/accounts".source = config.lib.file.mkOutOfStoreSymlink nixosConfig.ptsd.secrets.files.baresip-accounts.path;

              # For Fritz!Box supported Audio Codecs, checkout:
              # https://avm.de/service/fritzbox/fritzbox-7590/wissensdatenbank/publication/show/1008_Unterstutzte-Sprach-Codecs-bei-Internettelefonie
              ".baresip/config".text = ''
                  poll_method epoll
                  call_local_timeout 120
                  call_max_calls 4
                  module_path ${pkgs.baresip}/lib/baresip/modules
                  module stdio.so  # UI

                  module g711.so # Audio codec

                  module pulse.so  # Audio driver

                  ${optionalString (cfg.baresip.audioPlayer != "") ''
                  audio_player pulse,${cfg.baresip.audioPlayer}
                ''}
                  ${optionalString (cfg.baresip.audioSource != "") ''
                  audio_source pulse,${cfg.baresip.audioSource}
                ''}
                  ${optionalString (cfg.baresip.audioAlert != "") ''
                  # Ring
                  audio_alert pulse,${cfg.baresip.audioAlert}
                ''}

                  ${optionalString (cfg.baresip.sipListen != "") ''
                  sip_listen ${cfg.baresip.sipListen}
                ''}

                  ${optionalString (cfg.baresip.netInterface != "") ''
                  net_interface ${cfg.baresip.netInterface}
                ''}

                  module stun.so
                  module turn.so
                  module ice.so
                  module_tmp uuid.so
                  module_tmp account.so
                  module_app auloop.so
                  module_app contact.so
                  module_app menu.so
              '';
            };

            home.packages = with pkgs;
              [
                bubblewrap
                nsjail
              ] ++ optionals (cfg.baresip.enable) [ baresip ] ++ [
                swaylock
                grim
                slurp
                wl-clipboard
                wdisplays
              ] ++ optionals cfg.qt.enable [
                qt5.qtwayland
                libsForQt5.qtstyleplugins # required for QT_STYLE_OVERRIDE
              ];

            gtk = {
              enable = true;
              font = {
                name = "${cfg.fontSans} ${toString cfg.fontSize}";
                #package = pkgs.iosevka; # TODO: replace, pulls in i686-unsupported dependencies
              };
              iconTheme = {
                name = "Adwaita";
                package = pkgs.gnome3.adwaita-icon-theme;
              };
            };

            wayland.windowManager.sway = {
              enable = true;
              config =
                {
                  modifier = cfg.modifier;
                  keybindings = keybindings;
                  modes = modes;
                  window = {
                    commands = window_commands;
                    hideEdgeBorders = "smart";
                  };
                  fonts = fonts;
                  bars = [ ];

                  # use `swaymsg -t get_inputs`
                  input = {
                    "*" = {
                      natural_scroll = "enabled";
                      xkb_layout = "de";
                      xkb_numlock = if cfg.numlockAuto then "enabled" else "disabled";
                      repeat_delay = "200";
                      repeat_rate = "45";
                    };
                  };

                  focus.mouseWarping = false;

                  seat = {
                    "*" = {
                      xcursor_theme = "Adwaita 16";
                      hide_cursor = toString (cfg.hideCursorIdleSec * 1000);
                    };
                  };

                  startup = [
                    { command = "${config.programs.waybar.package}/bin/waybar"; }
                    { command = "${config.programs.foot.package}/bin/foot --server"; }
                    { command = toString pkgs.autoname-workspaces; }
                  ] ++ optional cfg.autolock.enable {
                    command = ''${pkgs.swayidle}/bin/swayidle -w \
        timeout 300 '${lockCmd}' \
        timeout 330 '${pkgs.sway}/bin/swaymsg "output * dpms off"' \
        resume '${pkgs.sway}/bin/swaymsg "output * dpms on"' \
        timeout 30 'if ${pkgs.procps}/bin/pgrep swaylock; then ${pkgs.sway}/bin/swaymsg "output * dpms off"; fi' \
        resume 'if ${pkgs.procps}/bin/pgrep swaylock; then ${pkgs.sway}/bin/swaymsg "output * dpms on"; fi' \
        before-sleep '${lockCmd}'
        '';
                  };
                };

              extraConfig = ''
                set $WOBSOCK $XDG_RUNTIME_DIR/wob.sock
              '';
            };

          };
      };
  };
}
