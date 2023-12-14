{ pkgs, ... }:
{
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/slack" = "slack.desktop";
  };
  home.packages = [ pkgs.slack ];
}
