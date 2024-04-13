{
  pkgs,
  lib,
  config,
  ...
}: let
  mbsync = "${config.programs.mbsync.package}/bin/mbsync";
  pass = "${config.programs.password-store.package}/bin/pass";

  common = rec {
    realName = "Gabriel Fontes";
    signature = {
      showSignature = "append";
      text = ''
        ${realName}

        https://gsfontes.com
      '';
    };
  };
in {
  home.persistence = {
    "/persist/home/misterio".directories = ["Mail"];
  };

  accounts.email = {
    maildirBasePath = "Mail";
    accounts = {
      personal =
        rec {
          primary = true;
          address = "hi@m7.rs";
          aliases = [
            "gabriel@gsfontes.com"
            "eu@misterio.me"
          ];
          passwordCommand = "${pass} ${smtp.host}/${address}";

          imap.host = "mail.m7.rs";
          mbsync = {
            enable = true;
            create = "maildir";
            expunge = "both";
          };
          folders = {
            inbox = "Inbox";
            drafts = "Drafts";
            sent = "Sent";
            trash = "Trash";
          };
          neomutt = {
            enable = true;
            extraMailboxes = [
              "Archive"
              "Drafts"
              "Junk"
              "Sent"
              "Trash"
            ];
          };

          msmtp.enable = true;
          smtp.host = "mail.m7.rs";
          userName = address;
        }
        // common;

      college =
        rec {
          address = "g.fontes@usp.br";
          passwordCommand = "${pass} ${smtp.host}/${address}";

          msmtp.enable = true;
          smtp.host = "smtp.gmail.com";
          userName = address;
        }
        // common;

      zoocha =
        rec {
          address = "gabriel@zoocha.com";
          passwordCommand = "${pass} ${smtp.host}/${address}";

          /*
          TODO: add imap (conditionally)
          imap.host = "imap.gmail.com";
          mbsync = {
            enable = true;
            create = "maildir";
            expunge = "both";
          };
          folders = {
            inbox = "INBOX";
            trash = "Trash";
          };
          neomutt = {
            enable = true;
          };
          */

          msmtp.enable = true;
          smtp.host = "smtp.gmail.com";
          userName = address;
        }
        // common;
    };
  };

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
}
