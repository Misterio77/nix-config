# Exposes a port through SSH
# xpo [local port] [remote host] [remote port]

{ writeShellApplication, openssh }: writeShellApplication {
  name = "xpo";
  runtimeInputs = [ openssh ];
  text = builtins.readFile ./xpo.sh;
}
