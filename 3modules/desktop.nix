{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.desktop;

  exit_mode = "exit: [l]ogout, [r]eboot, reboot-[w]indows, [s]hutdown, s[u]spend-then-hibernate, [h]ibernate, sus[p]end";
  open_codium_mode = "codium: [p]tsd, nobbo[f]in, [n]ixpkgs";

  terminalConfigs = {
    alacritty = rec {
      binary = "${pkgs.alacritty}/bin/alacritty";
      exec = prog: dir: "${binary}${if dir != "" then " --working-directory \"${dir}\"" else ""}${if prog != "" then " -e ${prog}" else ""}";
      extraPackages = [ ];
      extraAliases = { };
    };
    kitty = rec {
      binary = "${pkgs.kitty}/bin/kitty";
      exec = prog: dir: "${binary}${if dir != "" then " --directory \"${dir}\"" else ""}${if prog != "" then " ${prog}" else ""}";
      extraPackages = [ ];
      extraAliases.icat = "kitty +kitten icat";
    };
    urxvt = rec {
      binary = "${config.programs.urxvt.package}/bin/urxvt";
      exec = prog: dir: "${binary}${if dir != "" then " -cd \"${dir}\"" else ""}${if prog != "" then " -e ${prog}" else ""}";
      extraPackages = [ pkgs.xsel ]; # required by urxvt clipboard integration
      extraAliases = { };
    };
    xterm = rec {
      binary = "${pkgs.xterm}/bin/xterm";
      exec = prog: dir: "${binary}${if prog != "" then " -e ${prog}" else ""}"; # xterm does not support working directory switching
      extraPackages = [ ];
      extraAliases = { };
    };
  };

  term = terminalConfigs.${cfg.terminalConfig};

  lockCmd =
    if cfg.lockImage != "" then
      (if cfg.mode == "i3" then ''${pkgs.nwlock}/bin/nwlock "${cfg.lockImage}"'' else ''${pkgs.swaylock}/bin/swaylock --image "${cfg.lockImage}" --scaling center --color 000000 -f'')
    else
      (if cfg.mode == "i3" then "${pkgs.i3lock}/bin/i3lock" else "${pkgs.swaylock}/bin/swaylock --color 000000 -f");

  cwdCmd = if cfg.mode == "i3" then "${pkgs.xcwd}/bin/xcwd" else "${pkgs.swaycwd}/bin/swaycwd";

  keybindings =
    {
      "${cfg.modifier}+Return" = "exec ${term.exec "" ""}";
      "${cfg.modifier}+Shift+q" = "kill";
      #"${cfg.modifier}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";
      "${cfg.modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -show combi";

      "${cfg.modifier}+Left" = "focus left";
      "${cfg.modifier}+Down" = "focus down";
      "${cfg.modifier}+Up" = "focus up";
      "${cfg.modifier}+Right" = "focus right";

      "${cfg.modifier}+Shift+Left" = "move left";
      "${cfg.modifier}+Shift+Down" = "move down";
      "${cfg.modifier}+Shift+Up" = "move up";
      "${cfg.modifier}+Shift+Right" = "move right";

      "${cfg.modifier}+f" = "fullscreen toggle";

      "${cfg.modifier}+s" = "layout stacking";
      "${cfg.modifier}+w" = "layout tabbed";
      "${cfg.modifier}+e" = "layout toggle split";

      "${cfg.modifier}+Shift+space" = "floating toggle";
      "${cfg.modifier}+space" = "focus mode_toggle";

      # "Space-Hack" to fix the ordering in the generated config file
      # This prevents that i3 uses this order: 10, 1, 2, ...
      " ${cfg.modifier}+1" = "workspace $ws1";
      " ${cfg.modifier}+2" = "workspace $ws2";
      " ${cfg.modifier}+3" = "workspace $ws3";
      " ${cfg.modifier}+4" = "workspace $ws4";
      " ${cfg.modifier}+5" = "workspace $ws5";
      " ${cfg.modifier}+6" = "workspace $ws6";
      " ${cfg.modifier}+7" = "workspace $ws7";
      " ${cfg.modifier}+8" = "workspace $ws8";
      " ${cfg.modifier}+9" = "workspace $ws9";
      "${cfg.modifier}+0" = "workspace $ws10";

      "${cfg.modifier}+Shift+1" = "move container to workspace $ws1";
      "${cfg.modifier}+Shift+2" = "move container to workspace $ws2";
      "${cfg.modifier}+Shift+3" = "move container to workspace $ws3";
      "${cfg.modifier}+Shift+4" = "move container to workspace $ws4";
      "${cfg.modifier}+Shift+5" = "move container to workspace $ws5";
      "${cfg.modifier}+Shift+6" = "move container to workspace $ws6";
      "${cfg.modifier}+Shift+7" = "move container to workspace $ws7";
      "${cfg.modifier}+Shift+8" = "move container to workspace $ws8";
      "${cfg.modifier}+Shift+9" = "move container to workspace $ws9";
      "${cfg.modifier}+Shift+0" = "move container to workspace $ws10";

      "${cfg.modifier}+Shift+r" = if cfg.mode == "i3" then "restart" else "reload";

      "${cfg.modifier}+r" = "mode resize";

      "${cfg.modifier}+Shift+Delete" = "exec ${lockCmd}";
      "${cfg.modifier}+Shift+Return" = "exec ${term.exec "" "`${cwdCmd}`"}";
      "${cfg.modifier}+Shift+c" = "exec codium \"`${cwdCmd}`\"";
      "${cfg.modifier}+Shift+t" = "exec pcmanfm \"`${cwdCmd}`\"";

      "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 10%+";
      "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 10%-";

      "XF86AudioMute" = mkIf (cfg.audio.enable && cfg.primarySpeaker != null) "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute ${cfg.primarySpeaker} toggle";
      "XF86AudioLowerVolume" = mkIf (cfg.audio.enable && cfg.primarySpeaker != null) "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume ${cfg.primarySpeaker} -5%";
      "XF86AudioRaiseVolume" = mkIf (cfg.audio.enable && cfg.primarySpeaker != null) "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume ${cfg.primarySpeaker} +5%";
      "XF86AudioMicMute" = mkIf (cfg.audio.enable && cfg.primaryMicrophone != null) "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute ${cfg.primaryMicrophone} toggle";

      "XF86Calculator" = "exec ${term.exec "${pkgs.bc}/bin/bc -l" ""}";
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

      "${cfg.modifier}+h" = "focus left";
      "${cfg.modifier}+Shift+u" = "resize shrink width 20 px or 20 ppt";

      "${cfg.modifier}+j" = "focus down";
      "${cfg.modifier}+Shift+i" = "resize shrink height 20 px or 20 ppt";

      "${cfg.modifier}+k" = "focus up";
      "${cfg.modifier}+Shift+o" = "resize grow height 20 px or 20 ppt";

      "${cfg.modifier}+l" = "focus right";
      "${cfg.modifier}+Shift+p" = "resize grow width 20 px or 20 ppt";

      "${cfg.modifier}+Home" = "workspace 1";
      "${cfg.modifier}+Prior" = "workspace prev";
      "${cfg.modifier}+Next" = "workspace next";
      "${cfg.modifier}+End" = "workspace 10";
      "${cfg.modifier}+Tab" = "workspace back_and_forth";

      # not working
      #"${cfg.modifier}+p" = ''[instance="scratch-term"] scratchpad show'';

      "${cfg.modifier}+c" = ''mode "${open_codium_mode}"'';

      "${cfg.modifier}+Shift+e" = ''mode "${exit_mode}"'';

      "${cfg.modifier}+numbersign" = "split horizontal;; exec ${term.exec "" "`${cwdCmd}`"}";
      "${cfg.modifier}+minus" = "split vertical;; exec ${term.exec "" "`${cwdCmd}`"}";

      "${cfg.modifier}+a" = ''[class="Firefox"] scratchpad show'';
      "${cfg.modifier}+b" = ''[class="Firefox"] scratchpad show'';

      # Take a screenshot
      "${cfg.modifier}+Ctrl+Shift+4" = mkIf (builtins.elem "office" cfg.profiles) (
        if cfg.mode == "sway"
        #then ''exec ${pkgs.grim}/bin/grim -t png -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png''
        then ''exec ${pkgs.grim}/bin/grim -t png -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f -''
        else "exec ${pkgs.flameshot}/bin/flameshot gui"
      );
    };

  modes = {
    "${open_codium_mode}" = {
      "n" = ''exec codium /home/enno/repos/nixpkgs; mode "default"'';
      "p" = ''exec codium /home/enno/repos/ptsd; mode "default"'';
      "f" = ''exec codium /home/enno/repos/nobbofin; mode "default"'';
      "Escape" = ''mode "default"'';
      "Return" = ''mode "default"'';
    };

    "${exit_mode}" = {
      "l" = ''exec ${if cfg.mode == "i3" then "i3-msg" else "swaymsg"} exit; mode "default"'';
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
  };

  # to get the class of a window run `xprop WM_CLASS` and click on the window
  window_commands = [
    # not working
    #{
    #  command = ''floating enable, move to scratchpad'';
    #  criteria.instance = "scratch-term";
    #}
    {
      criteria.class = "Firefox";
      command = "floating enable, resize set 90 ppt 90 ppt, move position center, move to scratchpad, scratchpad show";
    }
    {
      criteria.class = ".blueman-manager-wrapped";
      command = "floating enable";
    }
    {
      criteria.class = "Pavucontrol";
      command = "floating enable";
    }
  ];

  fonts = [ "${cfg.fontSans} ${toString cfg.fontSize}" ];

  bars = [
    ({
      colors.background = "#181516";
      # font size must be appended to the *last* item in this list, see https://developer.gnome.org/pango/stable/pango-Fonts.html#pango-font-description-from-string
      fonts = [ cfg.fontMono "Material Design Icons" "Typicons" "Font Awesome 5 Free" "Font Awesome 5 Brands ${toString cfg.fontSize}" ];
      statusCommand = "exec ${pkgs.nwi3status}/bin/nwi3status";
      trayOutput = cfg.trayOutput;
    } // (optionalAttrs
      (cfg.mode == "sway")
      {
        extraConfig = ''
          icon_theme Tango
        '';
      }))
  ];

  extraConfig = ''
    set $ws1 1
    set $ws2 2
    set $ws3 3
    set $ws4 4
    set $ws5 5
    set $ws6 6
    set $ws7 7
    set $ws8 8
    set $ws9 9
    set $ws10 10
  '';

  all_profiles = {
    "3dprinting" = pkgs: with pkgs; [
      prusa-slicer
      freecad
      cura
      prusa-slicer
    ];
    "admin" = pkgs: with pkgs; [
      ethtool
      git
      gnupg
      lxqt.lxqt-policykit # provides a default authentification client for policykit
      xdg_utils
      gen-secrets
      syncthing-device-id
      nwvpn-qr
      paperkey
      nixpkgs-fmt
      #asciinema
      rclone
      teamviewer
      qrencode
      sshfs
      dnsmasq
      wireshark-qt
      freerdp
    ];
    "dev" = pkgs: with pkgs;
      let
        py3 = python3.override {
          packageOverrides = self: super: rec {
            black_nbconvert = self.callPackage ../5pkgs/black_nbconvert { };
          };
        };
        pyenv = py3.withPackages (
          pythonPackages: with pythonPackages; [
            black
            black_nbconvert
            jupyterlab
            lxml
            keyring
            nbconvert
            pandas
            pdfminer
            pillow
            requests
            selenium
          ]
        );
      in
      [
        gitAndTools.hub
        nix-tree
        nbconvert
        vscodium
        sqlitebrowser
        #filezilla
        sqlitebrowser
        gnumake
        #nix-deploy
        #hcloud
        dep2nix
        #dbeaver
        drone-cli
        #openshift
        #minishift
        cachix
        pyenv
        docker_compose


      ];
    "kvm" = pkgs: with pkgs;[
      virtviewer
      virtmanager
    ];
    "media" = pkgs: with pkgs;[
      #(
      #  ffmpeg-full.override {
      #    nonfreeLicensing = true;
      #    fdkaacExtlib = true;
      #    ffplayProgram = false;
      #    ffprobeProgram = false;
      #    qtFaststartProgram = false;
      #  }
      #)
      ffmpeg-full
      mpv
      imagemagick
      ffmpeg-normalize
      youtube-dl
      spotify
      vlc
      #mediathekview
      obs-studio
      v4l-utils
      pulseeffects-pw
    ];
    "office" = pkgs: with pkgs;
      let
        py3 = python3.override {
          packageOverrides = self: super: rec {
            davphonebook = self.callPackage ../5pkgs/davphonebook { };
          };
        };
      in
      [
        xournalpp
        #calibre
        (xmind.override { jre = openjdk11; })
        transmission-gtk
        fava
        anki
        sylpheed
        #zoom-us
        #nerdworks-motivation
        keepassxc
        (pdftk.override { jre = openjdk11; })
        libreoffice-fresh
        inkscape
        gimp
        portfolio
        shrinkpdf
        py3.pkgs.davphonebook
        teams
        aspell
        aspellDicts.de
        aspellDicts.en
        aspellDicts.en-computers
        aspellDicts.en-science

        hunspellDicts.de-de
        hunspellDicts.en-gb-large
        hunspellDicts.en-us-large


        tdesktop
        (drawio.overrideAttrs (oldAttrs: {
          # fix wrong file handling in default desktop file for file manager integration
          patchPhase = ''
            substituteInPlace usr/share/applications/drawio.desktop \
              --replace 'drawio %U' 'drawio %f'
          '';
        }))

        (writeTextFile {
          name = "drawio-mimetype";
          text = ''
            <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
              <mime-type type="application/vnd.jgraph.mxfile">
                <comment>draw.io Diagram</comment>
                <glob pattern="*.drawio" case-sensitive="true"/>
              </mime-type>
            </mime-info>
          '';
          destination = "/share/mime/packages/drawio.xml";
        })
        pdfduplex
        pdf2svg

        zathura
        zathura-single
        (makeDesktopItem {
          name = "zathura";
          desktopName = "Zathura";
          exec = "${pkgs.zathura}/bin/zathura %f";
          mimeType = "application/pdf";
          type = "Application";
        })
      ];
  };
in
{
  imports = [
    <home-manager/nixos>
  ];

  options = {
    ptsd.desktop = {
      enable = mkEnableOption "ptsd.desktop";
      mode = mkOption {
        default = "sway";
        type = types.strMatching "sway|i3";
      };
      pipewire.enable = mkOption {
        type = types.bool;
        default = true;
        description = "use pipewire instead of pulseaudio";
      };
      fontSans = mkOption {
        type = types.str;
        default = "Iosevka Sans"; # TODO: expose package, e.g. for gtk
      };
      fontMono = mkOption {
        type = types.str;
        default = "Iosevka";
      };
      fontSize = mkOption {
        type = types.int;
        default = 10;
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
      terminalConfig = mkOption {
        type = types.strMatching "alacritty|kitty|urxvt|xterm";
        default = "alacritty";
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
      backgroundImage = mkOption {
        type = types.str;
        default = "";
      };
      backgroundFill = mkOption {
        type = with types; nullOr (strMatching "#[0-9a-fA-F]{6}");
      };
      lockImage = mkOption {
        type = types.str;
        default = "";
      };
      userImage = mkOption {
        type = types.str;
        default = "";
      };
      hideCursorIdleSec = mkOption {
        type = types.int;
        default = 1;
      };
      nwi3status = mkOption {
        type = types.submodule {
          options = {
            openweathermapApiKey = mkOption {
              type = types.str;
              default = "";
            };
            todoistApiKey = mkOption {
              type = types.str;
              default = "";
            };
          };
        };
        default = { };
      };
      waybar.enable = mkOption {
        type = types.bool;
        default = config.ptsd.desktop.mode == "sway";
      };
      audio.enable = mkOption {
        type = types.bool;
        default = true;
      };
      bluetooth.enable = mkOption {
        type = types.bool;
        default = true;
      };
      qt.enable = mkOption {
        type = types.bool;
        default = true;
      };
      profiles = mkOption {
        type = with types; listOf str;
        description = "package profiles to configure, see all_profiles";
      };
    };
  };

  config = mkIf cfg.enable {

    xdg.portal = {
      enable = true;
      gtkUsePortal = true;
      extraPortals = with pkgs;[ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
    };

    services.xserver = mkIf (cfg.mode == "i3") {
      enable = true;

      layout = "de";

      libinput = {
        enable = true;
        clickMethod = "clickfinger";
        naturalScrolling = true;
      };

      desktopManager.xterm.enable = true;

      displayManager.lightdm = {
        background = mkIf (cfg.backgroundImage != "") cfg.backgroundImage;

        # move login box to bottom left and add logo
        greeters.gtk.extraConfig = mkIf (cfg.userImage != "") ''
          default-user-image=${cfg.userImage}
          position=42 -42
        '';
      };
    };

    security.pam.services.lightdm.enableGnomeKeyring = mkIf (builtins.elem "office" cfg.profiles) true;
    services.gnome3.gnome-keyring.enable = mkIf (builtins.elem "office" cfg.profiles) true;

    # required for evolution
    programs.dconf.enable = mkIf (builtins.elem "office" cfg.profiles) true;
    systemd.packages = mkIf (builtins.elem "office" cfg.profiles) [ pkgs.gnome3.evolution-data-server ];

    security.polkit.enable = true;

    virtualisation.spiceUSBRedirection.enable = mkIf (builtins.elem "kvm" cfg.profiles) true;

    environment.systemPackages = with pkgs; [
      libinput
      libnotify
    ] ++ optionals cfg.audio.enable [
      playerctl
      cadence
      qjackctl
      config.hardware.pulseaudio.package
      pavucontrol
      pasystray

    ]
    ++ optionals (cfg.mode == "i3") [
      redshift
      dunst
    ] ++ optionals (cfg.mode == "sway") [
      gammastep
    ]     ++ optionals (config.networking.networkmanager.enable && cfg.mode == "i3") [
      networkmanagerapplet
    ] ++ (flatten (map (profile: (all_profiles."${profile}" pkgs)) cfg.profiles));
    services.gvfs.enable = mkIf (builtins.elem "office" cfg.profiles) true; # allow smb:// mounts in pcmanfm

    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

    systemd.user.services."${if cfg.mode == "i3" then "redshift" else "gammastep"}" = {
      description = "Screen color temperature manager";
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = if cfg.mode == "i3" then "${pkgs.redshift}/bin/redshift" else "${pkgs.gammastep}/bin/gammastep";
        RestartSec = 3;
        Restart = "on-failure";
      };
    };

    systemd.user.services.nm-applet = mkIf (config.networking.networkmanager.enable && cfg.mode == "i3") {
      description = "Network Manager applet";
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      path = [ pkgs.dbus ];
      serviceConfig = {
        ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";
        RestartSec = 3;
        Restart = "always";
      };
    };

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
      iosevka
      nwfonts
      proggyfonts
      roboto
      roboto-slab
      source-code-pro
      win10fonts

      # required by nwi3status
      font-awesome_5
      material-design-icons
      typicons
    ];

    # for betaflight-configurator firmware flashing
    # from https://github.com/betaflight/betaflight/wiki/Installing-Betaflight#platform-specific-linux
    services.udev.extraRules = ''
      # DFU (Internal bootloader for STM32 MCUs)
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0664", GROUP="dialout"
    '';

    services.upower.enable = true;
    services.lorri.enable = true;

    sound.enable = true;

    systemd.user.services.pasystray = mkIf (cfg.audio.enable && cfg.mode == "i3" && !cfg.pipewire.enable) {
      description = "PulseAudio system tray";
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      path = [ pkgs.pavucontrol ];
      serviceConfig = {
        # Workaround from https://github.com/NixOS/nixpkgs/issues/7329 to make GTK-Themes work
        ExecStart = "${pkgs.bash}/bin/bash -c 'source ${config.system.build.setEnvironment}; exec ${pkgs.pasystray}/bin/pasystray'";
        RestartSec = 3;
        Restart = "always";
      };
    };

    hardware = {
      bluetooth = {
        enable = true;
        hsphfpd.enable = true;
        package = pkgs.bluezFull;
      };

      pulseaudio = {
        enable = cfg.audio.enable && !cfg.pipewire.enable;
        package = lib.mkDefault pkgs.pulseaudioFull; # pulseAudioFull required for bluetooth audio support
        #support32Bit = true; # for Steam

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

    # improved version of the pkgs.blueman-provided user service
    systemd.user.services.blueman-applet-nw = mkIf (cfg.bluetooth.enable && cfg.mode == "i3") {
      description = "Bluetooth management applet";
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        # Workaround from https://github.com/NixOS/nixpkgs/issues/7329 to make GTK-Themes work
        ExecStart = "${pkgs.bash}/bin/bash -c 'source ${config.system.build.setEnvironment}; exec ${pkgs.blueman}/bin/blueman-applet'";
        RestartSec = 3;
        Restart = "always";
      };
    };

    programs.sway = mkIf (cfg.mode == "sway") {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    # 20.09 compat (optionalAttrs instead of mkIf)
    services.pipewire = lib.optionalAttrs (cfg.audio.enable && cfg.pipewire.enable) {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
      media-session = {
        enable = true;
      };
    };

    security.rtkit.enable = cfg.audio.enable && cfg.pipewire.enable;

    home-manager =
      {
        users.mainUser = { config, pkgs, ... }:
          {

            imports = [
              <ptsd/3modules/home>
              #<ptsd/2configs/home/git-alarm.nix> # TODO: Port to nwi3status
            ];

            xsession = mkIf (cfg.mode == "i3") {
              enable = true;

              windowManager.i3 =
                {
                  enable = true;
                  config = {
                    modifier = cfg.modifier;
                    keybindings = keybindings;
                    modes = modes;
                    startup = [
                      { command = "i3-msg workspace 1"; notification = false; }
                    ];
                    window.commands = window_commands;
                    fonts = fonts;
                    bars = bars;
                  };
                  extraConfig = extraConfig;
                };

              pointerCursor = {
                package = pkgs.vanilla-dmz;
                name = "Vanilla-DMZ-AA";
              };
            };

            services.screen-locker = mkIf (cfg.mode == "i3") {
              enable = true;
              lockCmd = lockCmd;
              xssLockExtraOptions = [
                "-n"
                "${pkgs.nwlock}/libexec/xsecurelock/dimmer" # nwlock package wraps custom xsecurelock
                "-l" # make sure not to allow machine suspend before the screen saver is active
              ];
            };

            systemd.user.services.flameshot = mkIf (cfg.mode == "i3") {
              Unit = {
                Description = "Flameshot screenshot tool";
              };

              Service = {
                ExecStart = "${pkgs.flameshot}/bin/flameshot";
                RestartSec = 3;
                Restart = "on-failure";
              };
            };

            ptsd.pcmanfm = {
              enable = true;
              term = term.binary;

              actions = {
                pdfconcat = mkIf (builtins.elem "office" cfg.profiles) {
                  title = "Concat PDF files";
                  title_de = "PDF-Dateien aneinanderhängen";
                  mimetypes = [ "application/pdf" ];
                  cmd = # https://black.readthedocs.io/en/stable/the_black_code_style.html#line-length
                    let script = pkgs.writers.writePython3 "pdfconcat"
                      {
                        flakeIgnore = [ "E203" "E501" "W503" ];
                      }
                      (pkgs.substituteAll {
                        src = ./pdfconcat.py;
                        inherit (pkgs) pdftk;
                      });
                    in "${pkgs.alacritty}/bin/alacritty --hold -e ${script} %F";
                  # #"${script} %F";
                };

                pdfduplex = mkIf (builtins.elem "office" cfg.profiles) {
                  title = "Convert A & B PDF to Duplex-PDF";
                  title_de = "Konvertiere A & B PDF zu Duplex-PDF";
                  mimetypes = [ "application/pdf" ];
                  cmd = "${pkgs.pdfduplex}/bin/pdfduplex %F";
                  selectionCount = 2;
                };
              };

            };

            programs.waybar = mkIf cfg.waybar.enable {
              enable = true;
              systemd.enable = true;
              settings = [
                {
                  layer = "top";
                  position = "bottom";
                  #output = [
                  #  "DP-3"
                  #  "DP-4"
                  #  "eDP-1"
                  #  "HDMI-A-1"
                  #];
                  modules-left = [ "sway/workspaces" "sway/mode" ];
                  modules-center = [
                  ];
                  modules-right = [
                    "idle_inhibitor"
                  ]
                  ++ optional cfg.audio.enable
                    "pulseaudio" ++ [
                    "network"
                    "cpu"
                    "memory"
                    #"backlight"
                    "battery"
                    "clock"
                    "tray"
                  ];
                  modules = {

                    idle_inhibitor = {
                      format = "{icon}";
                      format-icons = {
                        activated = "";
                        deactivated = "";
                      };
                    };
                    cpu = {
                      format = "{usage}% ";
                      on-click-right = term.exec "${pkgs.htop}/bin/htop" "";
                    };
                    memory = {
                      format = "{}% ";
                      on-click-right = term.exec "${pkgs.procps}/bin/watch -n1 ${pkgs.coreutils}/bin/cat /proc/meminfo" "";
                    };
                    battery = {
                      states = { warning = 30; critical = 15; };
                      format = "{capacity}% {icon}";
                      format-charging = "{capacity}% ";
                      format-plugged = "{capacity}% ";
                      format-alt = "{time} {icon}";
                      format-icons = [ "" "" "" "" "" ];
                    };
                    clock.format-alt = "{:%a, %d. %b  %H:%M}";
                    network = {
                      format-wifi = "{essid} ({signalStrength}%) ";
                      format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
                      format-linked = "{ifname} (No IP) ";
                      format-disconnected = "Disconnected ⚠";
                      format-alt = "{ifname}: {ipaddr}/{cidr}";
                      on-click-right = term.exec "${pkgs.networkmanager}/bin/nmtui" "";
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
              style = ''
                * {
                    border: none;
                    border-radius: 0;
                    font-family: ${cfg.fontSans};
                    font-size: ${toString cfg.fontSize}pt;
                    min-height: 0;
                }

                window#waybar {
                    background-color: #002b36;
                    color: #d33682;
                    transition-property: background-color;
                    transition-duration: .5s;
                }

                window#waybar.hidden {
                    opacity: 0.2;
                }

                /*
                window#waybar.empty {
                    background-color: transparent;
                }
                window#waybar.solo {
                    background-color: #FFFFFF;
                }
                */

                window#waybar.termite {
                    background-color: #3F3F3F;
                }

                window#waybar.chromium {
                    background-color: #000000;
                    border: none;
                }

                #workspaces {
                    border-bottom: 1px solid #586e75;
                }

                /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
                #workspaces button {
                    padding: 0 5px;
                    background-color: transparent;
                    color: #657b83;
                    border-bottom: 3px solid transparent;
                }

                #workspaces button.focused {
                    background-color: #073642;
                    border-bottom: 1px solid #ff0;
                }

                #workspaces button.urgent {
                    background-color: #d33682;
                }

                #mode {
                    background-color: #002b36;
                    border-bottom: 1px solid #dc322f;
                }

                #clock, #battery, #cpu, #memory, #temperature, #backlight, #network, #pulseaudio, #custom-media, #tray, #mode, #idle_inhibitor {
                    padding: 0 10px;
                    margin: 0 2px;
                    color: #657b83;
                }
                /*
                #clock {
                    background-color: #073642;
                }
                */
                #battery {
                    background-color: #073642;
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
                    background-color: #073642;
                }

                #cpu {
                    background-color: #073642;
                }

                #memory {
                    background-color: #073642;
                }

                #backlight {
                    background-color: #073642;
                }

                #network {
                    background-color: #073642;
                }

                #network.disconnected {
                    background-color: #002b36;
                }

                #pulseaudio {
                    background-color: #073642;
                }

                #pulseaudio.muted {
                    background-color: #002b36;
                }

                #custom-media {
                    background-color: #66cc99;
                    color: #2a5c45;
                    min-width: 100px;
                }

                #custom-media.custom-spotify {
                    background-color: #66cc99;
                }

                #custom-media.custom-vlc {
                    background-color: #ffa000;
                }

                #temperature {
                    background-color: #073642;
                }

                #temperature.critical {
                    background-color: #dc322f;
                }

                #tray {
                    background-color: #002b36;
                }

                #idle_inhibitor {
                    background-color: #002b36;
                }

                #idle_inhibitor.activated {
                    background-color: #073642;
                }

              '';
            };


            home = {
              file.".mozilla/native-messaging-hosts/passff.json".source = "${pkgs.passff-host}/share/passff-host/passff.json";
              keyboard = {
                layout = "de";
                variant = "nodeadkeys";
              };
            };


            xdg.mimeApps = {
              enable = true;

              # verify using `xdg-mime query default <mimetype>`
              defaultApplications = {
                "application/pdf" = [ "zathura.desktop" ];
                "text/plain" = [ "vim.desktop" ];
                "image/gif" = [ "sxiv.desktop" ];
                "image/jpeg" = [ "sxiv.desktop" ];
                "image/png" = [ "sxiv.desktop" ];
                "inode/directory" = [ "pcmanfm.desktop" ];
                "text/html" = [ "chromium.desktop" "firefox.desktop" ];
                "x-scheme-handler/http" = [ "chromium.desktop" "firefox.desktop" ];
                "x-scheme-handler/https" = [ "chromium.desktop" "firefox.desktop" ];
                "x-scheme-handler/about" = [ "chromium.desktop" "firefox.desktop" ];
                "x-scheme-handler/unknown" = [ "chromium.desktop" "firefox.desktop" ];
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
            xdg.configFile."mimeapps.list".force = true;

            home.packages = with pkgs;[
              hicolor-icon-theme
              gnome3.file-roller
            ] ++ optionals (!cfg.waybar.enable) [ nwi3status ] ++ term.extraPackages ++ optionals
              (cfg.mode == "i3")
              [
                caffeine
                xorg.xev
                xorg.xhost
                flameshot
                i3lock # only needed for config testing / man pages
                nwlock
                brightnessctl
              ] ++ optionals
              (cfg.mode == "sway")
              [
                swaylock
                grim
                slurp
                wl-clipboard
              ] ++ optionals cfg.qt.enable [
              qt5.qtwayland
              libsForQt5.qtstyleplugins # required for QT_STYLE_OVERRIDE
            ];

            xdg.configFile."i3/nwi3status.toml" =
              let
                statusConfig = {
                  TodoistAPIKey = cfg.nwi3status.todoistApiKey;
                };
                statusConfigFile =
                  pkgs.runCommand
                    "nwi3status-config.toml"
                    {
                      buildInputs = [ pkgs.remarshal ];
                      preferLocalBuild = true;
                    }
                    ''
                      remarshal -if json -of toml \
                        < ${pkgs.writeText "config.json"
                        (builtins.toJSON statusConfig)} \
                        > $out
                    '';
              in
              {
                source = statusConfigFile;
                onChange =
                  if cfg.mode == "i3" then
                    ''
                      i3Socket=''${XDG_RUNTIME_DIR:-/run/user/$UID}/i3/ipc-socket.*
                      if [ -S $i3Socket ]; then
                        echo "Reloading i3"
                        $DRY_RUN_CMD ${pkgs.i3}/bin/i3-msg -s $i3Socket reload 1>/dev/null
                      fi
                    ''
                  else ''
                    swaySocket=''${XDG_RUNTIME_DIR:-/run/user/$UID}/sway-ipc.$UID.$(${pkgs.procps}/bin/pgrep -x sway || ${pkgs.coreutils}/bin/true).sock
                    if [ -S $swaySocket ]; then
                      echo "Reloading sway"
                      $DRY_RUN_CMD ${pkgs.sway}/bin/swaymsg -s $swaySocket reload
                    fi
                  '';
              };

            # auto-hide the mouse cursor after inactivity on i3/X11
            # sway has "hide_cursor" configuration option
            services.unclutter = mkIf
              (cfg.mode == "i3")
              {
                enable = true;
                timeout = cfg.hideCursorIdleSec;
              };

            # TODO: check if it also works for sway?
            services.dunst = mkIf
              (cfg.mode == "i3")
              {
                enable = true;
                settings = {
                  global = {
                    geometry = "300x5-30+50";
                    transparency = 10;
                    frame_color = "#eceff1";
                    font = "${cfg.fontMono} ${toString cfg.fontSize}";
                  };

                  urgency_normal = {
                    background = "#37474f";
                    foreground = "#eceff1";
                    timeout = 5;
                  };

                  urgency_low.timeout = 1;
                };
              };

            programs.zsh = {
              loginExtra = mkIf (cfg.mode == "sway") ''
                # If running from tty1 start sway
                if [ "$(tty)" = "/dev/tty1" ]; then
                  # pass sway log output to journald
                  exec ${pkgs.systemd}/bin/systemd-cat --identifier=sway ${pkgs.sway}/bin/sway
                fi
              '';
              shellAliases = term.extraAliases;
            };

            gtk = {
              enable = true;
              font = {
                name = "${cfg.fontSans} ${toString cfg.fontSize}";
                package = pkgs.iosevka;
              };
              iconTheme = {
                name = "Tango";
                package = pkgs.tango-icon-theme;
              };
              theme = {
                name = "Arc-Dark";
                package = pkgs.arc-theme;
              };
            };

            programs.rofi = {
              enable = true;
              font = "${cfg.fontSans} ${toString cfg.fontSize}";
              theme = "solarized_alternate";
              terminal = term.binary;
            };

            home.sessionVariables = {
              PASSWORD_STORE_DIR = "/home/enno/repos/password-store";
              QT_STYLE_OVERRIDE = "gtk2"; # for qt5 apps (e.g. keepassxc)
              TERMINAL = term.binary;
            } // optionalAttrs
              (cfg.mode == "sway")
              {
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
              };


            wayland.windowManager.sway = mkIf
              (cfg.mode == "sway")
              {
                enable = true;
                config =
                  {
                    modifier = cfg.modifier;
                    keybindings = keybindings;
                    modes = modes;
                    window.commands = window_commands;
                    fonts = fonts;
                    bars = if cfg.waybar.enable then [ ] else bars;

                    # use `swaymsg -t get_inputs`
                    input = {
                      "*" = {
                        natural_scroll = "enabled";
                        xkb_layout = "de";
                        xkb_numlock = "enabled";
                      };
                    };
                  };

                extraConfig = extraConfig + ''
                  seat * hide_cursor ${toString (cfg.hideCursorIdleSec * 1000)}
                  mouse_warping none
                  exec ${pkgs.swayidle}/bin/swayidle -w \
                      timeout 300 '${lockCmd}' \
                      timeout 330 '${pkgs.sway}/bin/swaymsg "output * dpms off"' \
                      resume '${pkgs.sway}/bin/swaymsg "output * dpms on"' \
                      timeout 30 'if ${pkgs.procps}/bin/pgrep swaylock; then ${pkgs.sway}/bin/swaymsg "output * dpms off"; fi' \
                      resume 'if ${pkgs.procps}/bin/pgrep swaylock; then ${pkgs.sway}/bin/swaymsg "output * dpms on"; fi' \
                      before-sleep '${lockCmd}'
                '' + optionalString (cfg.backgroundImage != "") ''
                  output "*" bg ${cfg.backgroundImage} fill${optionalString (cfg.backgroundFill != null) " ${cfg.backgroundFill}"}
                '';
              };

            programs.alacritty = mkIf
              (cfg.terminalConfig == "alacritty")
              {
                enable = true;
                settings = {
                  font = {
                    normal = {
                      family = cfg.fontMono;
                    };
                    size = cfg.fontSize;
                  };

                  # Colors (Solarized Dark)
                  colors = {
                    # Default colors
                    primary = {
                      background = "#002b36"; # base03
                      foreground = "#839496"; # base0
                    };

                    # Cursor colors
                    cursor = {
                      text = "#002b36"; # base03
                      cursor = "#839496"; # base0
                    };

                    # Normal colors
                    normal = {
                      black = "#073642"; # base02
                      red = "#dc322f"; # red
                      green = "#859900"; # green
                      yellow = "#b58900"; # yellow
                      blue = "#268bd2"; # blue
                      magenta = "#d33682"; # magenta
                      cyan = "#2aa198"; # cyan
                      white = "#eee8d5"; # base2
                    };

                    # Bright colors
                    bright = {
                      black = "#586e75"; # base01
                      red = "#cb4b16"; # orange
                      green = "#586e75"; # base01
                      yellow = "#657b83"; # base00
                      blue = "#839496"; # base0
                      magenta = "#6c71c4"; # violet
                      cyan = "#93a1a1"; # base1
                      white = "#fdf6e3"; # base3
                    };
                  };
                };
              };


            programs.urxvt =
              let
                themes = {
                  solarized_dark = {
                    "background" = "#002b36";
                    "foreground" = "#839496";
                    "fadeColor" = "#002b36";
                    "cursorColor" = "#93a1a1";
                    "pointerColorBackground" = "#586e75";
                    "pointerColorForeground" = "#93a1a1";
                    "color0" = "#073642";
                    "color8" = "#002b36";
                    "color1" = "#dc322f";
                    "color9" = "#cb4b16";
                    "color2" = "#859900";
                    "color10" = "#586e75";
                    "color3" = "#b58900";
                    "color11" = "#657b83";
                    "color4" = "#268bd2";
                    "color12" = "#839496";
                    "color5" = "#d33682";
                    "color13" = "#6c71c4";
                    "color6" = "#2aa198";
                    "color14" = "#93a1a1";
                    "color7" = "#eee8d5";
                    "color15" = "#fdf6e3";
                  };
                  solarized_light = {
                    "background" = "#fdf6e3";
                    "foreground" = "#657b83";
                    "fadeColor" = "#fdf6e3";
                    "cursorColor" = "#586e75";
                    "pointerColorBackground" = "#93a1a1";
                    "pointerColorForeground" = "#586e75";
                    "color0" = "#073642";
                    "color8" = "#002b36";
                    "color1" = "#dc322f";
                    "color9" = "#cb4b16";
                    "color2" = "#859900";
                    "color10" = "#586e75";
                    "color3" = "#b58900";
                    "color11" = "#657b83";
                    "color4" = "#268bd2";
                    "color12" = "#839496";
                    "color5" = "#d33682";
                    "color13" = "#6c71c4";
                    "color6" = "#2aa198";
                    "color14" = "#93a1a1";
                    "color7" = "#eee8d5";
                    "color15" = "#fdf6e3";
                  };
                };
              in
              mkIf
                (cfg.terminalConfig == "urxvt")
                {
                  enable = true;
                  extraConfig = {
                    saveLines = 100000;

                    urgentOnBell = true;

                    perl-ext-common = "default,clipboard,font-size,url-select,keyboard-select";

                    "url-select.underline" = true;
                    "url-select.launcher" = "${pkgs.xdg_utils}/bin/xdg-open";
                    "matcher.button" = 1; # allow left click on url

                    #termName = "rxvt-unicode"; # fix bash backspace not working
                    termName = "xterm";
                  } // themes."${cfg.theme}";
                  fonts = [
                    "xft:${cfg.fontMono}:size=${toString cfg.fontSize}"
                    "xft:${cfg.fontMono}:size=${toString cfg.fontSize}:bold"
                  ];
                  keybindings = {
                    # font size
                    "C-0x2b" = "font-size:increase"; # Ctrl+'+'
                    "C-0x2d" = "font-size:decrease"; # Ctrl+'-'
                    "C-0" = "font-size:reset";

                    # Common Keybinds for Navigation
                    "Shift-Up" = "command:\\033]720;1\\007"; # scroll one line higher
                    "Shift-Down" = "command:\\033]721;1\\007"; # scroll one line lower
                    "Control-Up" = "\\033[1;5A";
                    "Control-Down" = "\\033[1;5B";
                    "Control-Left" = "\\033[1;5D"; # jump to the previous word
                    "Control-Right" = "\\033[1;5C"; # jump to the next word
                    "Home" = "\\033[1~";
                    "KP_Home" = "\\033[1~";
                    "End" = "\\033[4~";
                    "KP_End" = "\\033[4~";

                    "Shift-Control-V" = "perl:clipboard:paste";

                    "M-u" = "perl:url-select:select_next";

                    "M-Escape" = "perl:keyboard-select:activate";
                    "M-s" = "perl:keyboard-select:search";

                    #"M-F1" = "command:\\033]710;xft:${cfg.font}:size=6\\007\\033]711;xft:${cfg.font}:size=6:bold\\007";
                    #"M-F2" = "command:\\033]710;xft:${cfg.font}:size=${toString cfg.fontSize}\\007\\033]711;xft:${cfg.font}:size=${toString cfg.fontSize}:bold\\007";
                    #"M-F3" = "command:\\033]710;xft:${cfg.font}:size=11\\007\\033]711;xft:${cfg.font}:size=11:bold\\007";
                    #"M-F4" = "command:\\033]710;xft:${cfg.font}:size=25\\007\\033]711;xft:${cfg.font}:size=25:bold\\007";
                    #"M-F5" = "command:\\033]710;xft:${cfg.font}:size=30\\007\\033]711;xft:${cfg.font}:size=30:bold\\007";
                  };
                };

            programs.kitty = {
              enable = lib.mkDefault (cfg.terminalConfig == "kitty");
              font.name = cfg.fontMono;

              # solarized dark
              # source: https://github.com/kovidgoyal/kitty/issues/897#issuecomment-419220650
              settings = {
                background = "#002b36";
                foreground = "#839496";
                cursor = "#93a1a1";
                selection_background = "#81908f";
                selection_foreground = "#002831";
                color0 = "#073642";
                color1 = "#dc322f";
                color2 = "#859900";
                color3 = "#b58900";
                color4 = "#268bd2";
                color5 = "#d33682";
                color6 = "#2aa198";
                color7 = "#eee8d5";
                color9 = "#cb4b16";
                color8 = "#002b36";
                color10 = "#586e75";
                color11 = "#657b83";
                color12 = "#839496";
                color13 = "#6c71c4";
                color14 = "#93a1a1";
                color15 = "#fdf6e3";

                font_size = cfg.fontSize;
              };

              keybindings = {
                "ctrl+plus" = "change_font_size all +2.0";
                "ctrl+minus" = "change_font_size all -2.0";
              };
            };

          };
      };
  };
}
