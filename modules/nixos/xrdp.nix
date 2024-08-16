{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.ptsd.xrdp;
  startwm = pkgs.writeShellScript "startwm.sh" ''
    . /etc/profile
    ${cfg.defaultWindowManager}
  '';
  sesmanConfig = {
    Globals = {
      ListenAddress = "127.0.0.1";
      ListenPort = 3350;
      EnableUserWindowManager = true;
      UserWindowManager = "startwm.sh";
      DefaultWindowManager = startwm;
      ReconnectScript = "reconnectwm.sh";
    };

    Security = {
      AllowRootLogin = true;
      MaxLoginRetry = 4;
      TerminalServerUsers = "tsusers";
      TerminalServerAdmins = "tsadmins";
      AlwaysGroupCheck = false;
    };

    Sessions = {
      X11DisplayOffset = 10;
      MaxSessions = 50;
      KillDisconnected = false;
      DisconnectedTimeLimit = 0;
      IdleTimeLimit = 0;
      Policy = "Default";
    };

    Logging = {
      LogFile = "/dev/null";
      EnableConsole = true;
      ConsoleLevel = "INFO";
    };

    Chansrv = {
      FuseMountName = "thinclient_drives";
    };

    SessionVariables = {
      LANG = "config.i18n.defaultLocale";
      LOCALE_ARCHIVE = "${config.i18n.glibcLocales}/lib/locale/locale-archive";
      PULSE_SCRIPT = "${cfg.package}/etc/xrdp/pulse/default.pa";
    };

    Xorg = {
      param = [
        "${pkgs.xorg.xorgserver}/bin/Xorg"
        "-modulepath"
        "${pkgs.xorgxrdp}/lib/xorg/modules,${pkgs.xorg.xorgserver}/lib/xorg/modules"
        "-config"
        "${pkgs.xorgxrdp}/etc/X11/xrdp/xorg.conf"
        "-noreset"
        "-nolisten"
        "tcp"
        "-logfile"
        ".xorgxrdp.%s.log"
        "-maxbigreqsize"
        "127"
      ];
    };
  };
  sesmanCfg = pkgs.writeText "sesman.ini" (
    lib.generators.toINI { listsAsDuplicateKeys = true; } sesmanConfig
  );
  xrdpConfig = {
    Globals = {
      ini_version = 1;
      fork = true;
      port = 3389;
      use_vsock = false;
      tcp_nodelay = true;
      tcp_keepalive = true;
      security_layer = "negotiate";
      crypt_level = "high";
      certificate = cfg.sslCert;
      key_file = cfg.sslKey;
      ssl_protocols = "TLSv1.2, TLSv1.3";
    };
    Logging = {
      LogFile = "/dev/null";
      EnableConsole = true;
      ConsoleLevel = "INFO";
    };
    Xorg = {
      name = "Xorg";
      lib = "libxup.so";
      username = "ask";
      password = "ask";
      ip = "127.0.0.1";
      port = -1;
      code = 20;
    };
  };
  xrdpCfg = pkgs.writeText "xrdp.ini" (lib.generators.toINI { } xrdpConfig);
in
{

  ###### interface

  options = {

    ptsd.xrdp = {

      enable = mkEnableOption "xrdp, the Remote Desktop Protocol server";

      package = mkOption {
        type = types.package;
        default = pkgs.xrdp;
        defaultText = literalExpression "pkgs.xrdp";
        description = lib.mdDoc ''
          The package to use for the xrdp daemon's binary.
        '';
      };

      sslKey = mkOption {
        type = types.str;
        default = "/etc/xrdp/key.pem";
        example = "/path/to/your/key.pem";
        description = lib.mdDoc ''
          ssl private key path
          A self-signed certificate will be generated if file not exists.
        '';
      };

      sslCert = mkOption {
        type = types.str;
        default = "/etc/xrdp/cert.pem";
        example = "/path/to/your/cert.pem";
        description = lib.mdDoc ''
          ssl certificate path
          A self-signed certificate will be generated if file not exists.
        '';
      };

      defaultWindowManager = mkOption {
        type = types.str;
        default = "xterm";
        example = "xfce4-session";
        description = lib.mdDoc ''
          The script to run when user log in, usually a window manager, e.g. "icewm", "xfce4-session"
          This is per-user overridable, if file ~/startwm.sh exists it will be used instead.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    # xrdp can run X11 program even if "services.xserver.enable = false"
    xdg = {
      autostart.enable = true;
      menus.enable = true;
      mime.enable = true;
      icons.enable = true;
    };

    fonts.enableDefaultFonts = mkDefault true;

    systemd = {
      services.xrdp = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        description = "xrdp daemon";
        requires = [ "xrdp-sesman.service" ];
        preStart = ''
          # prepare directory for unix sockets (the sockets will be owned by loggedinuser:xrdp)
          mkdir -p /tmp/.xrdp || true
          chown xrdp:xrdp /tmp/.xrdp
          chmod 3777 /tmp/.xrdp

          # generate a self-signed certificate
          if [ ! -s ${cfg.sslCert} -o ! -s ${cfg.sslKey} ]; then
            mkdir -p $(dirname ${cfg.sslCert}) || true
            mkdir -p $(dirname ${cfg.sslKey}) || true
            ${pkgs.openssl.bin}/bin/openssl req -x509 -newkey rsa:2048 -sha256 -nodes -days 365 \
              -subj /C=US/ST=CA/L=Sunnyvale/O=xrdp/CN=www.xrdp.org \
              -config ${cfg.package}/share/xrdp/openssl.conf \
              -keyout ${cfg.sslKey} -out ${cfg.sslCert}
            chown root:xrdp ${cfg.sslKey} ${cfg.sslCert}
            chmod 440 ${cfg.sslKey} ${cfg.sslCert}
          fi

          mkdir -p /run/xrdp/xrdp
          if [ ! -s /run/xrdp/xrdp/rsakeys.ini ]; then
            ${cfg.package}/bin/xrdp-keygen xrdp /run/xrdp/xrdp/rsakeys.ini
            chown xrdp:xrdp /run/xrdp/xrdp/rsakeys.ini
          fi
          cp ${cfg.package}/run/xrdp/xrdp/xrdp_keyboard.ini /run/xrdp/xrdp/xrdp_keyboard.ini
          cp ${cfg.package}/run/xrdp/xrdp/km-*.ini /run/xrdp/xrdp/
        '';
        serviceConfig = {
          User = "xrdp";
          Group = "xrdp";
          PermissionsStartOnly = true;
          ExecStart = "${cfg.package}/bin/xrdp --nodaemon --config ${xrdpCfg}";
        };
      };

      services.xrdp-sesman = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        description = "xrdp session manager";
        restartIfChanged = false; # do not restart on "nixos-rebuild switch". like "display-manager", it can have many interactive programs as children
        serviceConfig = {
          ExecStart = "${cfg.package}/bin/xrdp-sesman --nodaemon --config ${sesmanCfg}";
          ExecStop = "${pkgs.coreutils}/bin/kill -INT $MAINPID";
        };
      };

    };

    users.users.xrdp = {
      description = "xrdp daemon user";
      isSystemUser = true;
      group = "xrdp";
    };
    users.groups.xrdp = { };

    security.pam.services.xrdp-sesman = {
      allowNullPassword = true;
      startSession = true;
    };
  };

}
