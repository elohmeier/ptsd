{ config, pkgs, ... }:

{
  accounts.email.accounts = {
    "enno" = {
      address = "enno@nerdworks.de";
      realName = "Enno Lohmeier";
      primary = true;
      userName = "enno@nerdworks.de";
      passwordCommand = "${pkgs.pass}/bin/pass mail/enno@nerdworks.de";
      imap = {
        host = "imap.dd24.net";
      };
      mbsync = {
        enable = true;
        create = "maildir";
      };
    };
  };

  programs.mbsync = {
    enable = true;
  };
}
