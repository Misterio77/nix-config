{pkgs, ...}: {
  home.packages = with pkgs; [khal];
  xdg.configFile."khal/config".text =
    /*
    toml
    */
    ''
      [calendars]

      [[calendars]]
      path = ~/Calendars/*
      type = discover

      [locale]
      timeformat = %H:%M
      dateformat = %d/%m/%Y
    '';
}
