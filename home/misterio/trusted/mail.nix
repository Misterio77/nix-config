{ pkgs, persistence, lib, config, ... }:

let
  mbsync = "${config.programs.mbsync.package}/bin/mbsync";
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
        address = "hi@m7.rs";

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
          extraMailboxes = [ "Archive" "Drafts" "Sent" "Spam" "Trash" ];
        };
        imap.host = "mail.m7.rs";
        smtp.host = "mail.m7.rs";
        userName = address;
        passwordCommand = "${pass} ${smtp.host}/${address}";
      } // common;
      college = rec {
        address = "g.fontes@usp.br";

        msmtp.enable = true;
        smtp.host = "smtp.gmail.com";
        userName = address;
        passwordCommand = "${pass} ${smtp.host}/${address}";
      } // common;
      work = rec {
        address = "gabriel.fontes@uget.express";

        msmtp.enable = true;
        smtp.host = "smtp.gmail.com";
        userName = address;
        passwordCommand = "${pass} ${smtp.host}/${address}";
      } // common;
    };
  };

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;

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
}
