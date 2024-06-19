{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.services.rgbdaemon;
in {
  options.services.rgbdaemon = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable rgbdaemon
      '';
    };
    package = mkOption {
      type = types.package;
      default = pkgs.rgbdaemon;
    };
    interval = mkOption {
      type = types.float;
      default = 0.8;
      description = ''
        Daemon main loop interval
      '';
    };
    daemons = {
      mute = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable mute button daemon
        '';
      };
      swayLock = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable swaylock status daemon
        '';
      };
      player = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable media player status daemon
        '';
      };
    };
    colors = let
      mkColorOption = name: {
        inherit name;
        value = mkOption {
          type = types.strMatching "[a-fA-F0-9]{6}";
          description = "${name} color.";
          default = "ffffff";
        };
      };
    in
      listToAttrs (
        map mkColorOption [
          "background"
          "foreground"
          "secondary"
          "tertiary"
          "quaternary"
        ]
      );
    mouse = {
      model = mkOption {
        type = types.str;
        description = "Mouse model name";
        default = "CORSAIR SCIMITAR RGB ELITE Gaming Mouse";
      };
      dpi = mkOption {
        type = types.int;
        description = "Mouse DPI";
        default = 750;
      };
      highlighted = mkOption {
        type = types.listOf types.str;
        description = "Always highlighted mouse keys";
        default = [];
      };
    };
    keyboard = {
      model = mkOption {
        type = types.str;
        description = "Keyboard model name";
        default = "CORSAIR K70 RGB MK.2 Mechanical Gaming Keyboard";
      };
      highlighted = mkOption {
        type = types.listOf types.str;
        description = "Always highlighted keyboard keys";
        default = [];
      };
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."rgbdaemon.conf" = {
      text = ''
        DAEMON_INTERVAL="${lib.strings.floatToString cfg.interval}"
        KEYBOARD_MODEL="${cfg.keyboard.model}"
        MOUSE_MODEL="${cfg.mouse.model}"
        KEYBOARD_HIGHLIGHTED="${lib.concatStringsSep "," cfg.keyboard.highlighted}"
        MOUSE_HIGHLIGHTED="${lib.concatStringsSep "," cfg.mouse.highlighted}"
        COLOR_BACKGROUND="${cfg.colors.background}"
        COLOR_FOREGROUND="${cfg.colors.foreground}"
        COLOR_SECONDARY="${cfg.colors.secondary}"
        COLOR_TERTIARY="${cfg.colors.tertiary}"
        COLOR_QUATERNARY="${cfg.colors.quaternary}"
        ENABLE_SWAY_LOCK="${toString cfg.daemons.swayLock}"
        ENABLE_MUTE="${toString cfg.daemons.mute}"
        ENABLE_PLAYER="${toString cfg.daemons.player}"
      '';
      onChange = ''
        ${pkgs.procps}/bin/pkill -u $USER -f -SIGHUP rgbdaemon || true
      '';
    };
    systemd.user.services.rgbdaemon = {
      Unit = {
        Description = "Misterio RGB Daemon";
      };
      Service = {
        ExecStart = "${cfg.package}/bin/rgbdaemon";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "always";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
