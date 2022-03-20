{ config, lib, pkgs, ... }:

let
  mailcap = pkgs.writeText "mailcap" ''
    text/html; ${pkgs.w3m}/bin/w3m -I %{charset} -T text/html; copiousoutput;
    application/pdf; ${pkgs.zathura}/bin/zathura %s
  '';
in
{
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.neomutt = {
    enable = true;
    settings.mailcap_path = toString mailcap;
    sidebar.enable = true;
    vimKeys = true;
  };
  programs.notmuch = {
    enable = true;
    hooks = {
      preNew = "mbsync --all";
    };
  };
  accounts.email = {
    accounts.nerdworks = {
      address = "enno@nerdworks.de";
      imap.host = "mail.nerdworks.de";
      mbsync = {
        enable = true;
        create = "maildir";
      };
      msmtp.enable = true;
      neomutt.enable = true;
      notmuch.enable = true;
      primary = true;
      realName = "Enno Richter";
      signature = {
        text = ''
          Mit freundlichen Grüßen
          Enno Richter

          -- 
          Enno Richter

          Nerdworks Hamburg
          Beim Schlump 53
          20144 Hamburg

          Telefon: +49 (0) 40 348 692 63
          Fax: +49 (0) 40 228 603 21
          E-Mail: enno@nerdworks.de
          www.nerdworks.de

          Diese E-Mail ist vertraulich. Wenn Sie nicht der rechtmäßige Empfänger
          sind, dürfen Sie den Inhalt weder kopieren, verbreiten oder benutzen.
          Sollten Sie diese E-Mail versehentlich erhalten haben, senden Sie sie
          bitte an mich zurück und löschen sie anschließend.
          This email is confidential. If you are not the intended recipient, you
          must not copy, disclose or use its contents. If you have received it in
          error, please inform me immediately by returning this email and delete
          the document afterwards.
        '';
        showSignature = "append";
      };
      passwordCommand = "pass mail.nerdworks.de/enno@nerdworks.de";
      smtp = {
        host = "mail.nerdworks.de";
      };
      userName = "enno@nerdworks.de";
    };
  };
}
