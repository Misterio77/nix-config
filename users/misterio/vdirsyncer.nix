{ pkgs, ... }:
{
  home.packages = with pkgs; [ vdirsyncer ];

  home.persistence."/data/home/misterio" = {
    directories = [
      "Calendars"
      "Contacts"
    ];
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
    url = "https://webmail.gandi.net/SOGo/dav"
    username = "eu@misterio.me"
    password.fetch = ["command", "pass", "mail.gandi.net/eu@misterio.me"]

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
    url = "https://webmail.gandi.net/SOGo/dav"
    username = "eu@misterio.me"
    password.fetch = ["command", "pass", "mail.gandi.net/eu@misterio.me"]
  '';

  systemd.user.services.vdirsyncer = {
    Unit = { Description = "vdirsyncer synchronization"; };
    Service = {
      Type = "oneshot";
      ExecCondition = ''
        /bin/sh -c '${pkgs.gnupg}/bin/gpg-connect-agent "KEYINFO --no-ask B5076D6AB0783A842150876E8047AEE5604FB663 Err Pmt Des" /bye | grep " 1 "'
      '';
      ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
    };
  };
  systemd.user.timers.vdirsyncer = {
    Unit = { Description = "Automatic vdirsyncer synchronization"; };
    Timer = {
      OnBootSec = "30";
      OnUnitActiveSec = "1m";
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };
}
