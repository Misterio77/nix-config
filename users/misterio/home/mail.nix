{ pkgs, ... }:

let
  common = rec {
    msmtp.enable = true;
    realName = "Gabriel Fontes";
    gpg = {
      key = "7088 C742 1873 E0DB 97FF 17C2 245C AB70 B4C2 25E9";
      signByDefault = true;
    };
    signature = {
      showSignature = "append";
      text = ''
        ${realName}

        https://misterio.me
        PGP: ${gpg.key}
      '';
    };
  };
in {
  home.persistence."/data/home/misterio".directories = [ "Mail" ];
  accounts.email = {
    maildirBasePath = "Mail";
    accounts = {
      personal = rec {
        primary = true;
        address = "eu@misterio.me";
        userName = address;
        passwordCommand = "pass smtp.mailbox.org/${address}";
        imap.host = "imap.mailbox.org";
        smtp.host = "smtp.mailbox.org";
        folders = { inbox = "INBOX"; };
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
        };
        neomutt = {
          enable = true;
          extraMailboxes = [ "Drafts" "Sent" "Trash" "Archive" ];
        };
      } // common;
      college = rec {
        address = "g.fontes@usp.br";
        userName = address;
        passwordCommand = "pass smtp.gmail.com/${address}";
        imap.host = "imap.gmail.com";
        smtp.host = "smtp.gmail.com";
      } // common;
      work = rec {
        address = "gabriel.fontes@uget.express";
        userName = address;
        passwordCommand = "pass smtp.gmail.com/${address}";
        imap.host = "imap.gmail.com";
        smtp.host = "smtp.gmail.com";
      } // common;
    };
  };
}
