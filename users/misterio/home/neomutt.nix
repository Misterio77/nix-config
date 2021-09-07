{... }:

{
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.neomutt = {
    enable = true;
    vimKeys = true;
    checkStatsInterval = 60;
    sidebar = {
      enable = true;
      width = 30;
    };
    settings = {
      mark_old = "no";
      text_flowed = "yes";
      reverse_name = "yes";
    };
    binds = [
      {
        action = "sidebar-toggle-visible";
        key = "\\\\";
        map = [ "index" "pager" ];
      }
    ];
    macros = [
      {
        action = "<sidebar-next><sidebar-open>";
        key = "J";
        map = [ "index" "pager" ];
      }
      {
        action = "<sidebar-prev><sidebar-open>";
        key = "K";
        map = [ "index" "pager" ];
      }
    ];
    extraConfig = ''
      color hdrdefault blue black
      color quoted blue black
      color signature blue black
      color attachment red black
      color prompt brightmagenta black
      color message brightred black
      color error brightred black
      color indicator black red
      color status brightwhite black
      color tree white black
      color normal white black
      color markers red black
      color search white black
      color tilde brightmagenta black
      color index blue black ~F
      color index red black "~N|~O"
    '';
  };
}
