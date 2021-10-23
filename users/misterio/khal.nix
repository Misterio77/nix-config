{ pkgs, ... }:
{
  home.packages = with pkgs; [ khal ];
  xdg.configFile."khal/config".text = ''
    [calendars]

    [[personal]]
    path = ~/Calendars/personal
    color = light magenta

    [[uget]]
    path = ~/Calendars/3CCD-613E1900-311-38A00200
    color = light red

    [[usp]]
    path = ~/Calendars/3CCD-613E1700-30D-38A00200/
    color = light cyan

    [locale]
    timeformat = %H:%M
    dateformat = %d/%m/%Y
  '';
}
