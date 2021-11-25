{ pkgs, lib, features, hostname, ... }:

let
  keyring = import ../trusted/keyring.nix { inherit pkgs; };
  swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  pgrep = "${pkgs.procps}/bin/pgrep";

  lockTime = if hostname == "atlas" then 600 else 240;
  isLocked = "${pgrep} -x swaylock";
  actionLock = "${swaylock} --screenshots --daemonize";
  actionMute = "${pactl} set-source-mute @DEFAULT_SOURCE@ yes";
  actionUnmute = "${pactl} set-source-mute @DEFAULT_SOURCE@ no";
  actionRgbOff = "systemctl --user stop rgbdaemon";
  actionRgbOn = "systemctl --user start rgbdaemon";
  actionDisplayOff = "swaymsg \"output * dpms off\"";
  actionDisplayOn = "swaymsg \"output * dpms on\"";
in
{
  # Remove pgp passphrase cache after 4 minutes
  # Lock after 10 minutes
  # After 10 seconds of locked, mute mic
  # After 20 seconds of locked, disable rgb lights and turn monitors off
  xdg.configFile."swayidle/config".text = ''
    before-sleep        '${actionLock}'
    timeout ${toString lockTime} '${actionLock}'

    timeout ${toString (lockTime + 10)} '${actionMute}' resume  '${actionUnmute}'
    timeout 10  '${isLocked} && ${actionMute}' resume  '${isLocked} && ${actionUnmute}'

    timeout ${toString (lockTime + 20)} '${actionDisplayOff}' resume  '${actionDisplayOn}'
    timeout 20  '${isLocked} && ${actionDisplayOff}' resume  '${isLocked} && ${actionDisplayOn}'
  '' +

  (if builtins.elem "trusted" features then ''
    timeout ${toString (lockTime / 3)} '${keyring.lock}'
  '' else "") +

  (if builtins.elem "rgb" features then ''
    timeout ${toString (lockTime + 20)} '${actionRgbOff}' resume  '${actionRgbOn}'
    timeout 20  '${isLocked} && ${actionRgbOff}' resume  '${isLocked} && ${actionRgbOn}'
  '' else "");
}
