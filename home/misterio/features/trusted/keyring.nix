{ pkgs, ... }:

let
  ssh = "${pkgs.openssh}/bin/ssh";
  gpg-connect-agent = "${pkgs.gnupg}/bin/gpg-connect-agent";
in
{
  isUnlocked = "${pkgs.procps}/bin/pgrep 'gpg-agent' &> /dev/null && ${gpg-connect-agent} 'scd getinfo card_list' /bye | ${pkgs.gnugrep}/bin/grep SERIALNO -q";
  unlock = "${ssh} -T localhost -o StrictHostKeyChecking=no exit";
}
