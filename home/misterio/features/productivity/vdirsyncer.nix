{ pkgs, lib, config, ... }:
let
  pass = "${config.programs.password-store.package}/bin/pass";
in
{
  home.packages = with pkgs; [ vdirsyncer ];

  home.persistence = {
    "/persist/home/misterio".directories =
      [ "Calendars" "Contacts" ".local/share/vdirsyncer" ];
  };

  xdg.configFile."vdirsyncer/config".text = ''
    [general]
    status_path = "~/.local/share/vdirsyncer/status"

    [pair contacts]
    a = "contacts_local"
    b = "contacts_remote"
    collections = ["from a", "from b"]
    conflict_resolution = "b wins"

    [storage contacts_local]
    type = "filesystem"
    path = "~/Contacts"
    fileext = ".vcf"

    [storage contacts_remote]
    type = "carddav"
    url = "https://dav.m7.rs"
    username = "hi@m7.rs"
    password.fetch = ["command", "${pass}", "mail.m7.rs/hi@m7.rs"]

    [pair calendars]
    a = "calendars_local"
    b = "calendars_remote"
    collections = ["from a", "from b"]
    metadata = ["color"]
    conflict_resolution = "b wins"

    [storage calendars_local]
    type = "filesystem"
    path = "~/Calendars"
    fileext = ".ics"

    [storage calendars_remote]
    type = "caldav"
    url = "https://dav.m7.rs"
    username = "hi@m7.rs"
    password.fetch = ["command", "${pass}", "mail.m7.rs/hi@m7.rs"]
  '';

  systemd.user.services.vdirsyncer = {
    Unit = { Description = "vdirsyncer synchronization"; };
    Service =
      let gpgCmds = import ../cli/gpg-commands.nix { inherit pkgs; };
      in
      {
        Type = "oneshot";
        ExecCondition = ''
          /bin/sh -c "${gpgCmds.isUnlocked}"
        '';
        ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
      };
  };
  systemd.user.timers.vdirsyncer = {
    Unit = { Description = "Automatic vdirsyncer synchronization"; };
    Timer = {
      OnBootSec = "30";
      OnUnitActiveSec = "5m";
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };
}
