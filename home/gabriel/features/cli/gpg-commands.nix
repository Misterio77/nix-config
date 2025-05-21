{pkgs, config, lib, ...}: let
  ssh = lib.getExe config.programs.openssh.package;
  pgrep = lib.getExe' pkgs.procps "pgrep";
  grep = lib.getExe pkgs.gnugrep;
  gpg-connect-agent = lib.getExe' config.programs.gpg.package "gpg-connect-agent";
in {
  isUnlocked = "${pgrep} 'gpg-agent' &> /dev/null && ${gpg-connect-agent} 'scd getinfo card_list' /bye | ${grep} SERIALNO -q";
  lock = "${gpg-connect-agent} reloadagent /bye";
  unlock = "${ssh} localhost exit";
}
