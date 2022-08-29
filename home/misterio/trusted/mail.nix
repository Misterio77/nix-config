{ pkgs, persistence, lib, config, ... }:

let
  pass = "${config.programs.password-store.package}/bin/pass";
  common = rec {
    msmtp.enable = true;
    realName = "Gabriel Fontes";
    gpg = {
      key = "7088 C742 1873 E0DB 97FF 17C2 245C AB70 B4C2 25E9";
      signByDefault = true;
    };
    signature = {
      showSignature = "append";
      # TODO update domain
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
        userName = address;
        passwordCommand = "${pass} mail1.netim.hosting/${address}";
        imap.host = "mail1.netim.hosting";
        smtp.host = "mail1.netim.hosting";
        folders = {
          inbox = "INBOX";
        };
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
        };
        neomutt = {
          enable = true;
          extraMailboxes = [ "Drafts" "Sent" "Trash" "Archive" "Junk" ];
        };
      } // common;
      college = rec {
        address = "g.fontes@usp.br";
        userName = address;
        passwordCommand = "${pass} smtp.gmail.com/${address}";
        imap.host = "imap.gmail.com";
        smtp.host = "smtp.gmail.com";
      } // common;
      work = rec {
        address = "gabriel.fontes@uget.express";
        userName = address;
        passwordCommand = "${pass} smtp.gmail.com/${address}";
        imap.host = "imap.gmail.com";
        smtp.host = "smtp.gmail.com";
      } // common;
    };
  };

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  systemd.user.services.mbsync = {
    Unit = { Description = "mbsync synchronization"; };
    Service = let keyring = import ./keyring.nix { inherit pkgs; };
    in {
      Type = "oneshot";
      ExecCondition = ''
        /bin/sh -c "${keyring.isUnlocked}"
      '';
      ExecStart = "${pkgs.isync}/bin/mbsync -a";
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
