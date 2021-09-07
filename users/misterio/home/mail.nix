{ pkgs, ... }:

let
  common = rec {
    msmtp.enable = true;
    mbsync = {
      enable = true;
      create = "maildir";
      expunge = "both";
    };
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
  gmail = name: {
    imap.host = "imap.gmail.com";
    smtp.host = "smtp.gmail.com";
    folders = {
      inbox = "INBOX";
      drafts = "[Gmail]/Drafts";
      sent = "[Gmail]/Sent Mail";
      trash = "[Gmail]/Trash";
    };
    neomutt = {
      enable = true;
      extraMailboxes = [
        {
          mailbox = "INBOX";
          name = "${name}/Inbox";
        }
        {
          mailbox = "[Gmail]/Drafts";
          name = "${name}/Drafts";
        }
        {
          mailbox = "[Gmail]/Sent Mail";
          name = "${name}/Sent";
        }
        {
          mailbox = "[Gmail]/Trash";
          name = "${name}/Trash";
        }
        {
          mailbox = "[Gmail]/All Mail";
          name = "${name}/Archive";
        }
      ];
      # Gmail already saves sent messages
      extraConfig = "unset record";
    };
  };
  mailbox = name: {
    imap.host = "imap.mailbox.org";
    smtp.host = "smtp.mailbox.org";
    folders = { inbox = "INBOX"; };
    neomutt = {
      enable = true;
      extraMailboxes = [
        {
          mailbox = "INBOX";
          name = "${name}/Inbox";
        }
        {
          mailbox = "Drafts";
          name = "${name}/Drafts";
        }
        {
          mailbox = "Sent";
          name = "${name}/Sent";
        }
        {
          mailbox = "Trash";
          name = "${name}/Trash";
        }
        {
          mailbox = "Archive";
          name = "${name}/Archive";
        }
      ];
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
      } // common // mailbox "personal";
      college = rec {
        address = "g.fontes@usp.br";
        userName = address;
        passwordCommand = "pass smtp.gmail.com/${address}";
      } // common // gmail "college";
      work = rec {
        address = "gabriel.fontes@uget.express";
        userName = address;
        passwordCommand = "pass smtp.gmail.com/${address}";
      } // common // gmail "work";
    };
  };
}
