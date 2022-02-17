{ pkgs, ... }:

let
  ssh = "${pkgs.openssh}/bin/ssh";
  gpg-connect-agent = "${pkgs.gnupg}/bin/gpg-connect-agent";
  keygrip = "149F16412997785363112F3DBD713BC91D51B831";
in {
  isUnlocked = "${gpg-connect-agent} 'scd getinfo card_list' /bye | grep SERIALNO -q";
  unlock = "${ssh} -T localhost -o StrictHostKeyChecking=no exit";
}
