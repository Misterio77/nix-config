{config, pkgs, lib, ...}: let
  pass = "${config.programs.password-store.package}/bin/pass";
  oama = "${config.programs.oama.package}/bin/oama";
in {
  home.persistence = {
    "/persist/${config.home.homeDirectory}".directories = [
      "Calendars"
      "Contacts"
      ".local/share/vdirsyncer"
    ];
  };

  accounts.calendar = {
    basePath = "Calendars";
    accounts = {
      personal = let
        emailCfg = config.accounts.email.accounts.personal;
      in {
        primary = true;
        primaryCollection = "Personal";
        khal = {
          enable = true;
          addresses = [emailCfg.address] ++ emailCfg.aliases;
          type = "discover";
        };
        remote = rec {
          type = "caldav";
          url = "https://dav.m7.rs";
          userName = emailCfg.address;
          passwordCommand = ["${pass}" "mail.m7.rs/${userName}"];
        };
        vdirsyncer = {
          enable = true;
          metadata = ["color" "displayname"];
          collections = ["from a" "from b"];
        };
      };

      usp = let
        emailCfg = config.accounts.email.accounts.usp;
      in {
        primaryCollection = emailCfg.address;
        khal = {
          enable = true;
          addresses = [emailCfg.address];
          type = "discover";
        };
        remote = {
          type = "google_calendar";
        };
        vdirsyncer = {
          enable = true;
          metadata = ["color" "displayname"];
          collections = ["from a" "from b"];
          accessTokenCommand = [oama "access" emailCfg.address];
        };
      };

      rug = let
        emailCfg = config.accounts.email.accounts.rug;
      in {
        primaryCollection = emailCfg.address;
        khal = {
          enable = true;
          addresses = [emailCfg.address];
          type = "discover";
        };
        remote = {
          type = "google_calendar";
        };
        vdirsyncer = {
          enable = true;
          metadata = ["color" "displayname"];
          collections = ["from a" "from b"];
          accessTokenCommand = [oama "access" emailCfg.address];
        };
      };
    };
  };

  programs.vdirsyncer.enable = true;
  services.vdirsyncer.enable = true;

  # Only run if gpg is unlocked
  systemd.user.services.vdirsyncer.Service.ExecCondition = let
    gpgCmds = import ../cli/gpg-commands.nix {inherit pkgs config lib;};
  in ''
    /bin/sh -c "${gpgCmds.isUnlocked}"
  '';
}
