{ lib, config, ... }:
let
  cfg = config.wayland.windowManager.hyprland;
in
{
  config = lib.mkIf (cfg.enable && cfg.systemdIntegration) {
    # Stolen from https://github.com/alebastr/sway-systemd/commit/0fdb2c4b10beb6079acd6073c5b3014bd58d3b74
    systemd.user.targets.hyprland-session-shutdown = {
      Unit = {
        Description = "Shutdown running Hyprland session";
        DefaultDependencies = "no";
        StopWhenUnneeded = "true";

        Conflicts = [
          "graphical-session.target"
          "graphical-session-pre.target"
          "hyprland-session.target"
        ];
        After = [
          "graphical-session.target"
          "graphical-session-pre.target"
          "hyprland-session.target"
        ];
      };
    };
    wayland.windowManager.hyprland.settings.bind = lib.mkAfter [
      "SUPERSHIFT,e,exec,systemctl --user start hyprland-session-shutdown.target; hyprctl dispatch exit"
    ];
  };
}
