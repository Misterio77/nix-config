{ pkgs, ... }:

let
  keyring = import ./keyring.nix { inherit pkgs; };
  swaylock = "${pkgs.swaylock-effects}/bin/swaylock";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  pgrep = "${pkgs.procps}/bin/pgrep";
in {
  # Remove pgp passphrase cache after 4 minutes
  # Lock after 10 minutes
  # After 10 seconds of locked, mute mic
  # After 20 seconds of locked, disable rgb lights and turn monitors off
  xdg.configFile."swayidle/config".text = ''
    timeout 240 '${keyring.lock}'

    timeout 600 '${swaylock} --screenshots --daemonize'

    timeout 10  '${pgrep} -x swaylock && ${pactl} set-source-mute @DEFAULT_SOURCE@ yes' resume  '${pgrep} -x swaylock && ${pactl} set-source-mute @DEFAULT_SOURCE@ no'
    timeout 610 '${pactl} set-source-mute @DEFAULT_SOURCE@ yes' resume  '${pactl} set-source-mute @DEFAULT_SOURCE@ no'

    timeout 20  '${pgrep} -x swaylock && systemctl --user stop rgbdaemon' resume  '${pgrep} -x swaylock && systemctl --user start rgbdaemon'
    timeout 620 'systemctl --user stop rgbdaemon' resume  'systemctl --user start rgbdaemon'

    timeout 20  '${pgrep} -x swaylock && swaymsg "output * dpms off"' resume  '${pgrep} -x swaylock && swaymsg "output * dpms on"'
    timeout 620 'swaymsg "output * dpms off"' resume  'swaymsg "output * dpms on"'
  '';
}
