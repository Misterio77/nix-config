# Exposes a port through SSH
# xpo [local port] [remote host] [remote port]

{ lib, writeShellApplication, openssh }: (writeShellApplication {
  name = "xpo";
  runtimeInputs = [ openssh ];
  text = builtins.readFile ./xpo.sh;
}) // {
  meta = with lib; {
    licenses = licenses.mit;
    platforms = platforms.all;
  };
}
