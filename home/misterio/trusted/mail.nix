{ pkgs, persistence, lib, config, ... }:

let
  mbsync = "${config.programs.mbsync.package}/bin/mbsync";
  gpg = "${config.programs.gnupg.package}/bin/gpg";
  pass = "${config.programs.password-store.package}/bin/pass";

  common = rec {
    realName = "Gabriel Fontes";
    gpg = {
      key = "7088 C742 1873 E0DB 97FF 17C2 245C AB70 B4C2 25E9";
      signByDefault = true;
    };
    signature = {
      showSignature = "append";
      text = ''
        ${realName}

        https://gsfontes.com
        PGP: ${gpg.key}
      '';
    };
  };
in
{
  home.persistence = lib.mkIf persistence {
    "/persist/home/misterio".directories = [ "Mail" ];
  };

  accounts.email = {
    maildirBasePath = "Mail";
    accounts = {
      personal = rec {
        primary = true;
        address = "gabriel@gsfontes.com";

        folders = {
          inbox = "Inbox";
          drafts = "Drafts";
          sent = "Sent";
          trash = "Trash";
        };
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
        };
        msmtp = {
          enable = true;
        };
        neomutt = {
          enable = true;
          mailboxName = "Personal -> Inbox";
          extraMailboxes = [ "Archive" "Drafts" "Sent" "Spam" "Trash" ];
        };
        imap.host = "imap.fastmail.com";
        smtp.host = "smtp.fastmail.com";
        userName = address;
        passwordCommand = "${pass} ${smtp.host}/${address}";
      } // common;
      college = rec {
        address = "g.fontes@usp.br";

        folders = {
          inbox = "Inbox";
          drafts = "[Gmail]/Drafts";
          sent = "[Gmail]/Sent";
          trash = "[Gmail]/Trash";
        };
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
        };
        msmtp = {
          enable = true;
        };
        neomutt = {
          enable = true;
          mailboxName = "USP -> Inbox";
          extraMailboxes = [ "[Gmail]/All Mail" "[Gmail]/Drafts" "[Gmail]/Spam" "[Gmail]/Sent Mail" "[Gmail]/Trash" ];
        };
        imap.host = "imap.gmail.com";
        smtp.host = "smtp.gmail.com";
        userName = address;
        passwordCommand = "${pass} ${smtp.host}/${address}";
      } // common;
      work = rec {
        address = "gabriel.fontes@uget.express";

        folders = {
          inbox = "Inbox";
          drafts = "[Gmail]/Drafts";
          sent = "[Gmail]/Sent";
          trash = "[Gmail]/Trash";
        };
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
        };
        msmtp = {
          enable = true;
        };
        neomutt = {
          enable = true;
          mailboxName = "U-Get -> Inbox";
          extraMailboxes = [ "[Gmail]/All Mail" "[Gmail]/Drafts" "[Gmail]/Spam" "[Gmail]/Sent Mail" "[Gmail]/Trash" ];
        };
        imap.host = "imap.gmail.com";
        smtp.host = "smtp.gmail.com";
        userName = address;
        passwordCommand = "${pass} ${smtp.host}/${address}";
      } // common;
    };
  };

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;

  /*
    systemd.user.services.mbsync = {
    Unit = { Description = "mbsync synchronization"; };
    Service =
    let keyring = import ./keyring.nix { inherit pkgs; };
    in
    {
    Type = "oneshot";
    ExecCondition = ''
    /bin/sh -c "${keyring.isUnlocked}"
    '';
    ExecStart = "${mbsync} -a";
    };
    };
    systemd.user.timers.mbsync = {
    Unit = { Description = "Automatic mbsync synchronization"; };
    Timer = {
    OnBootSec = "30";
    OnUnitActiveSec = "5m";
    };
    Install = { WantedBy = [ "timers.target" ]; };
    };
  */
}
