{pkgs, config, lib, ...}: let
  pgrep = lib.getExe' pkgs.procps "pgrep";
  grep = lib.getExe pkgs.gnugrep;
  gpg-connect-agent = lib.getExe' config.programs.gpg.package "gpg-connect-agent";
  gpgconf = lib.getExe' config.programs.gpg.package "gpgconf";
in {
  # TODO: this does not REALLY queries if the PIN is cached, only if the card has been used by the agent
  # So, this always indicated that the card is at least plugged in, but the user might be prompted for a pin anyway.
  isUnlocked = "${pgrep} 'gpg-agent' &> /dev/null && ${gpg-connect-agent} 'scd getinfo card_list' /bye | ${grep} SERIALNO -q";
  lock = "${gpg-connect-agent} reloadagent /bye";
  unlock = "SSH_AUTH_SOCK=$(${gpgconf} --list-dirs agent-ssh-socket) ssh localhost exit";
}
