{ pkgs, ... }: {
  home.packages = with pkgs; [ khal ];
  xdg.configFile."khal/config".text = ''
    [calendars]

    [[personal]]
    path = ~/Calendars/personal

    [[uget]]
    path = ~/Calendars/3CCD-613E1900-311-38A00200

    [[usp]]
    path = ~/Calendars/3CCD-613E1700-30D-38A00200/

    [locale]
    timeformat = %H:%M
    dateformat = %d/%m/%Y
  '';
}
