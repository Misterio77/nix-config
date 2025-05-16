{config, lib, pkgs, ...}: {
  services.hypridle = {
    enable = true;
    settings = let
      lock = lib.getExe config.programs.hyprlock.package;
      isLocked = "pgrep -f ${lock}";
      displayOn = "hyprctl dispatch dpms on";
      displayOff = "hyprctl dispatch dpms off";
      lockTime = 120;
      script = text: lib.getExe (pkgs.writeShellScriptBin "script" text);
    in {
      general = {
        lock_cmd = lock;
        before_sleep_cmd = lock;
        after_sleep_cmd = displayOn;
      };
      listener = [
        # Before locked
        {
          timeout = 20;
          on-timeout = "brightnessctl --save --device *:kbd_backlight set 0";
          on-resume = "brightnessctl --restore --device *:kbd_backlight";
        }
        {
          timeout = 20;
          on-timeout = "light -O && light -U 30";
          on-resume = "light -I";
        }
        {
          timeout = lockTime - 10;
          on-timeout = "light -U 40";
          on-resume = "light -I";
        }

        # Lock
        {
          timeout = lockTime;
          on-timeout = lock;
        }

        # After locked
        {
          timeout = lockTime + 20;
          on-timeout = displayOff;
          on-resume = displayOn;
        }
        {
          timeout = 25;
          on-timeout = script "if ${isLocked}; then ${displayOff}; fi";
          on-resume = displayOn;
        }
      ];
    };
  };
}
