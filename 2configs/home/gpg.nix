{ config, lib, pkgs, ... }:

{
  programs.gpg = {
    enable = true;
    settings.throw-keyids = true;
    scdaemonSettings.disable-ccid = lib.mkIf pkgs.stdenv.isDarwin true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = pkgs.stdenv.isLinux;
    extraConfig = ''
      # https://github.com/drduh/config/blob/master/gpg-agent.conf
      # https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html
      default-cache-ttl 60
      max-cache-ttl 120
    '';
    pinentryFlavor = if pkgs.stdenv.isLinux then "gnome3" else "tty";
  };

  home.activation.addGpgPublicKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $VERBOSE_ECHO "Adding & trusting GPG public keys"
    $DRY_RUN_CMD gpg --import ${../../src/pubkeys/enno.gpg}
    $DRY_RUN_CMD gpg --import ${../../src/pubkeys/pass_iph3.gpg}
    $DRY_RUN_CMD echo -e "5\ny\n" | gpg --command-fd 0 --expert --edit-key 807BC3355DA0F069 trust
    $DRY_RUN_CMD echo -e "5\ny\n" | gpg --command-fd 0 --expert --edit-key F5EAA91650FAB83F trust
  '';
}
