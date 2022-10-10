{ pkgs, lib, config, ... }:

let
  swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  pgrep = "${pkgs.procps}/bin/pgrep";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  swaymsg = "${pkgs.sway}/bin/swaymsg";

  isLocked = "${pgrep} -x swaylock";
  actionLock = "${swaylock} -S --daemonize";

  lockTime = 4*60; # TODO: configurable desktop (10 min)/laptop (4 min)

  mkEvent = time: start: resume: ''
    timeout ${toString (lockTime + time)} '${start}' ${lib.optionalString (resume != null) "resume '${resume}'"}
    timeout ${toString time} '${isLocked} && ${start}' ${lib.optionalString (resume != null) "resume '${isLocked} && ${resume}'"}
  '';
in
{
  xdg.configFile."swayidle/config".text = ''
    timeout ${toString lockTime} '${actionLock}'
  '' +
  # After 10 seconds of locked, mute mic
  (mkEvent 10 "${pactl} set-source-mute @DEFAULT_SOURCE@ yes" "${pactl} set-source-mute @DEFAULT_SOURCE@ no") +
  # If has RGB, turn it off 20 seconds after locked
  lib.optionalString config.services.rgbdaemon.enable
    (mkEvent 20 "systemctl --user stop rgbdaemon" "systemctl --user start rgbdaemon") +
  # Hyprland - Turn off screen (DPMS)
  lib.optionalString config.wayland.windowManager.hyprland.enable
    (mkEvent 40 "${hyprctl} dispatch dpms off" "${hyprctl} dispatch dpms on") +
  # Sway - Turn off screen (DPMS)
  lib.optionalString config.wayland.windowManager.hyprland.enable
    (mkEvent 40 "${swaymsg} 'output * dpms off'" "${swaymsg} 'output * dpms on'");
}
