{config, lib, ...}: {
  services.hypridle = {
    enable = true;
    settings = let
      lock = lib.getExe config.programs.hyprlock.package;
      isLocked = "pgrep -f ${lock}";
      displayOn = "hyprctl dispatch dpms on";
      displayOff = "hyprctl dispatch dpms off";
      lockTime = 120;
    in {
      general = {
        lock_cmd = lock;
        before_sleep_cmd = lock;
        after_sleep_cmd = displayOn;
      };
      listener = [
        {
          timeout = 20;
          on-timeout = "light -O && light -U 40";
          on-resume = "light -I";
        }
        {
          timeout = 20;
          on-timeout = "brightnessctl --save --device *:kbd_backlight set 0";
          on-resume = "brightnessctl --restore --device *:kbd_backlight";
        }

        {
          timeout = lockTime;
          on-timeout = lock;
        }

        {
          timeout = lockTime + 25;
          on-timeout = displayOff;
          on-resume = displayOn;
        }
        {
          timeout = 25;
          on-timeout = "${isLocked} && ${displayOff}";
          on-resume = displayOn;
        }
      ];
    };
  };
}
