{ pkgs, lib, hostname, config, ... }:

let
  swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  pgrep = "${pkgs.procps}/bin/pgrep";

  isLocked = "${pgrep} -x swaylock";
  actionLock = "${swaylock} -S --daemonize";

  # Lock after 10 (desktop) or 4 (laptop) minutes
  lockTime = (if (hostname == "pleione") then 4 else 10) * 60;

  mkEvent = time: start: resume: ''
    timeout ${toString (lockTime + time)} '${start}' ${lib.optionalString (resume != null) "resume '${resume}'"}
    timeout ${toString time} '${isLocked} && ${start}' ${lib.optionalString (resume != null) "resume '${isLocked} && ${resume}'"}
  '';
in
{
  xdg.configFile."swayidle/config".text = ''
    timeout ${toString lockTime} '${actionLock}'
  ''
  # After 10 seconds of locked, mute mic
  + (mkEvent 10 "${pactl} set-source-mute @DEFAULT_SOURCE@ yes" "${pactl} set-source-mute @DEFAULT_SOURCE@ no")
  # If has RGB, turn it off 20 seconds after locked
  + lib.optionalString config.services.rgbdaemon.enable
    (mkEvent 120 "systemctl --user stop rgbdaemon" "systemctl --user start rgbdaemon");
}
