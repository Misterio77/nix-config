{
  pkgs,
  lib,
  config,
  ...
}: let
  mbsync = "${config.programs.mbsync.package}/bin/mbsync";
  pass = "${config.programs.password-store.package}/bin/pass";
  oama = "${config.programs.oama.package}/bin/oama";

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

  gmail_channels = {
    Inbox = {
      farPattern = "INBOX";
      nearPattern = "Inbox";
      extraConfig = {
        Create = "Near";
        Expunge = "Both";
      };
    };
    Archive = {
      farPattern = "Archived Mail";
      nearPattern = "Archive";
      extraConfig = {
        Create = "Both";
        Expunge = "Both";
      };
    };
    Junk = {
      farPattern = "[Gmail]/Spam";
      nearPattern = "Junk";
      extraConfig = {
        Create = "Near";
        Expunge = "Both";
      };
    };
    Trash = {
      farPattern = "[Gmail]/Trash";
      nearPattern = "Trash";
      extraConfig = {
        Create = "Near";
        Expunge = "Both";
      };
    };
    Drafts = {
      farPattern = "[Gmail]/Drafts";
      nearPattern = "Drafts";
      extraConfig = {
        Create = "Near";
        Expunge = "Both";
      };
    };
    Sent = {
      farPattern = "[Gmail]/Sent Mail";
      nearPattern = "Sent";
      extraConfig = {
        Create = "Near";
        Expunge = "Both";
      };
    };
  };
in {
  home.persistence = {
    "/persist/${config.home.homeDirectory}".directories = ["Mail"];
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
          userName = address;
          passwordCommand = "${pass} ${smtp.host}/${address}";

          imap.host = "mail.m7.rs";
          mbsync = {
            enable = true;
            create = "maildir";
            expunge = "both";
          };
          neomutt = {
            enable = true;
            mailboxName = "=== Personal ===";
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
        }
        // common;

      rug =
        rec {
          address = "g.silva.fontes@student.rug.nl";
          userName = address;
          passwordCommand = "${oama} access ${address}";
          flavor = "gmail.com";

          mbsync = {
            enable = true;
            create = "maildir";
            expunge = "both";
            groups.gmail.channels = gmail_channels;
            extraConfig.account.AuthMechs = "XOAUTH2";
          };
          neomutt = {
            enable = true;
            mailboxName = "=== RUG ===";
            extraMailboxes = [
              "Archive"
              "Drafts"
              "Junk"
              "Sent"
              "Trash"
            ];
          };

          msmtp = {
            extraConfig.auth = "oauthbearer";
            enable = true;
          };
        }
        // common;

      usp =
        rec {
          address = "g.fontes@usp.br";
          userName = address;
          passwordCommand = "${oama} access ${address}";
          flavor = "gmail.com";

          mbsync = {
            enable = true;
            create = "maildir";
            expunge = "both";
            groups.gmail.channels = gmail_channels;
            extraConfig.account.AuthMechs = "XOAUTH2";
          };
          neomutt = {
            enable = true;
            mailboxName = "=== USP ===";
            extraMailboxes = [
              "Archive"
              "Drafts"
              "Junk"
              "Sent"
              "Trash"
            ];
          };

          msmtp = {
            extraConfig.auth = "oauthbearer";
            enable = true;
          };
        }
        // common;
    };
  };

  programs.mbsync = {
    enable = true;
    package = pkgs.isync.override {
      withCyrusSaslXoauth2 = true;
    };
  };
  programs.msmtp.enable = true;

  systemd.user.services.mbsync = {
    Unit = {
      Description = "mbsync synchronization";
    };
    Service = let
      gpgCmds = import ../cli/gpg-commands.nix {inherit pkgs;};
    in {
      Type = "oneshot";
      ExecCondition = ''
        /bin/sh -c "${gpgCmds.isUnlocked}"
      '';
      ExecStart = "${mbsync} -a";
    };
  };
  systemd.user.timers.mbsync = {
    Unit = {
      Description = "Automatic mbsync synchronization";
    };
    Timer = {
      OnBootSec = "30";
      OnUnitActiveSec = "5m";
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };

  # Run 'createMaildir' after 'linkGeneration'
  home.activation = let
    mbsyncAccounts = lib.filter (a: a.mbsync.enable) (lib.attrValues config.accounts.email.accounts);
  in
    lib.mkIf (mbsyncAccounts != []) {
      createMaildir = lib.mkForce (lib.hm.dag.entryAfter ["linkGeneration"] ''
        run mkdir -m700 -p $VERBOSE_ARG ${
          lib.concatMapStringsSep " " (a: a.maildir.absPath) mbsyncAccounts
        }
      '');
    };
}
