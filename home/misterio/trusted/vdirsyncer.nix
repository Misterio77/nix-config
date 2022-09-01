{ pkgs, persistence, lib, config, ... }:
let pass = "${config.programs.password-store.package}/bin/pass";
in {
  home.packages = with pkgs; [ vdirsyncer ];

  home.persistence = lib.mkIf persistence {
    "/persist/home/misterio".directories =
      [ "Calendars" "Contacts" ".local/share/vdirsyncer" ];
  };

  # TODO: migrate caldav and carddav elsewhere
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
    password.fetch = ["command", "${pass}", "mail.gandi.net/eu@misterio.me"]

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
    password.fetch = ["command", "${pass}", "mail.gandi.net/eu@misterio.me"]
  '';
}
