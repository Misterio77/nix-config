{ config, lib, pkgs, ... }:
let
  cfg = config.wayland.windowManager.hyprland;
in
{
  options.wayland.windowManager.hyprland = {
    enable = lib.mkEnableOption "hyprland wayland compositor";
    package = lib.mkOption {
      type = with lib.types; nullOr package;
      default = pkgs.hyprland;
    };
    systemdIntegration = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.isLinux;
    };
    xwayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional (cfg.package != null) cfg.package
      ++ lib.optional cfg.xwayland pkgs.xwayland;

    xdg.configFile."hypr/hyprland.conf" =
      let
        hyprlandPackage = if cfg.package == null then pkgs.hyprland else cfg.package;
      in
      {
        text =
          (lib.optionalString cfg.systemdIntegration ''
            exec-once=${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE
            exec-once=systemctl --user start hyprland-session.target
          '') +
          cfg.extraConfig;
        onChange = ''
          ${hyprlandPackage}/bin/hyprctl reload
        '';
      };


    systemd.user.targets.hyprland-session = lib.mkIf cfg.systemdIntegration {
      Unit = {
        Description = "hyprland compositor session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };

    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [ "graphical-session-pre.target" ];
      };
    };
  };
}
