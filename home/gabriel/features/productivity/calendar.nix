{config, pkgs, lib, ...}: let
  pass = "${config.programs.password-store.package}/bin/pass";
  oama = "${config.programs.oama.package}/bin/oama";
in {
  home.persistence = {
    "/persist".directories = [
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
          collections = [
            "Personal"
            "projects"
            "ideas"
            "reading-list"
            "routine"
            "7eebf97d-5962-5fcd-4e73-888f22720cee" # Casa
            "Postgrad"
            "GELOS"
            "3ce52be8-d87e-4b4d-8225-a9c65840c72e" # Magalu
          ];
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
    };
  };

  programs.vdirsyncer.enable = true;
  services.vdirsyncer.enable = true;

  # Only run if gpg is unlocked
  systemd.user.services.vdirsyncer.Service = {
    ExecCondition = let
      gpgCmds = import ../cli/gpg-commands.nix {inherit pkgs config lib;};
    in ''
      /bin/sh -c "${gpgCmds.isUnlocked}"
    '';
    Restart = "on-failure";
    StartLimitBurst = 2;
    ExecStopPost = pkgs.writeShellScript "stop-post" ''
      # When it requires a discovery
      if [ "$SERVICE_RESULT" == "exit-code" ]; then
        ${lib.getExe config.services.vdirsyncer.package} discover --no-list
      fi
    '';
  };
}
