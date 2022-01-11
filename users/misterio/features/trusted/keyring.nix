{ pkgs, ... }:

let
  ssh = "${pkgs.openssh}/bin/ssh";
  gpg-connect-agent = "${pkgs.gnupg}/bin/gpg-connect-agent";
  keygrip = "149F16412997785363112F3DBD713BC91D51B831";
in {
  isUnlocked =
    "${gpg-connect-agent} 'KEYINFO --list' /bye | grep ${keygrip} | grep -E 'D . . 1' -q";
  lock = "${gpg-connect-agent} reloadagent /bye";
  unlock = "${ssh} -T localhost -o StrictHostKeyChecking=no exit";
}
