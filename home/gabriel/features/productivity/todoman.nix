{config, ...}: {
  programs.todoman = {
    enable = true;
    glob = "*/*";
    extraConfig = ''
      default_list = "${config.accounts.calendar.accounts.personal.primaryCollection}"
      date_format = "%d/%m/%Y"
      time_format = "%H:%M"
      humanize = True
      default_due = 0
    '';
  };
  programs.fish.interactiveShellInit = /* fish */ ''
    complete -xc todo -a '(__fish_complete_bash)'
  '';
}
