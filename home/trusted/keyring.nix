{ pkgs, ... }:

let
  ssh = "${pkgs.openssh}/bin/ssh";
  gpg-connect-agent = "${pkgs.gnupg}/bin/gpg-connect-agent";
in {
  isUnlocked = "${gpg-connect-agent} 'scd getinfo card_list' /bye | grep SERIALNO -q";
  unlock = "${ssh} -T localhost -o StrictHostKeyChecking=no exit";
}
