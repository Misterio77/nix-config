{ pkgs, rgb, laptop, ... }:

let
  swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  pgrep = "${pkgs.procps}/bin/pgrep";

  lockTime = if laptop then 240 else 600;
  isLocked = "${pgrep} -x swaylock";
  actionLock = "${swaylock} -S --daemonize";
  actionMute = "${pactl} set-source-mute @DEFAULT_SOURCE@ yes";
  actionUnmute = "${pactl} set-source-mute @DEFAULT_SOURCE@ no";
  actionRgbOff = "systemctl --user stop rgbdaemon";
  actionRgbOn = "systemctl --user start rgbdaemon";
  actionDisplayOff = ''swaymsg "output * dpms off"'';
  actionDisplayOn = ''swaymsg "output * dpms on"'';
in
{
  # Lock after 10 (desktop) or 4 (laptop) minutes
  # After 10 seconds of locked, mute mic
  # After 20 seconds of locked, disable rgb lights and turn monitors off
  # If has PGP, lock it after lockTime/4
  # If has RGB, turn off 20 seconds after locked
  xdg.configFile."swayidle/config".text = ''
    timeout ${toString lockTime} '${actionLock}'

    timeout ${toString (lockTime + 10)} '${actionMute}' resume  '${actionUnmute}'
    timeout 10 '${isLocked} && ${actionMute}' resume  '${isLocked} && ${actionUnmute}'

    timeout ${toString (lockTime + 20)} '${actionDisplayOff}' resume  '${actionDisplayOn}'
    timeout 20 '${isLocked} && ${actionDisplayOff}' resume  '${isLocked} && ${actionDisplayOn}'
  '' +

  (if rgb then ''
    timeout ${toString (lockTime + 20)} '${actionRgbOff}' resume  '${actionRgbOn}'
    timeout 20 '${isLocked} && ${actionRgbOff}' resume  '${isLocked} && ${actionRgbOn}'
  '' else "");
}
