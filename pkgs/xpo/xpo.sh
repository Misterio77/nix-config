#!/usr/bin/env bash
# Exposes a port through SSH
# xpo [local port] [remote host] [remote port]
#
# Arguments:
# - local port: defaults to 8080
# - remote host: defaults to $XPO_SERVER
# - remote port: defaults to randomly chosen
#
# Environment variables:
# - $XPO_SERVER: server to ssh into
# - $XPO_SSH_USER: override user used to ssh, defaults to $USER
# - $XPO_SSH_OPTS: additional ssh options, defaults to "-A"

socket="${XDG_RUNTIME_DIR:-/run/user/${UID:-1000}}/xpo-$BASHPID.sock"
server="${2:-$XPO_SERVER}"
user="${XPO_SSH_USER:-$USER}"
l_port="${1:-8080}"
ssh_opts="${XPO_SSH_OPTS:-"-A"}"

# Open master ssh connection
ssh -fTN "$ssh_opts" -MS "$socket" "$user@$server"

echo "Forwarding :$l_port" >&2

# If port was supplied
if [ -n "${3:-}" ]; then
    r_port="$3"
    ssh -S "$socket" -O forward -R "*:$r_port:localhost:$l_port" xpo
else
    # Forward port and record it
    r_port="$(ssh -S "$socket" -O forward -R "*:0:localhost:$l_port" xpo)"
fi

echo "$server:$r_port"

# Open it through iptables
echo -n "Opening $r_port on firewall... " >&2
ssh "$ssh_opts" -t -S "$socket" xpo -- sudo iptables -I INPUT -p tcp --dport "$r_port" -j ACCEPT
echo "done" >&2

clean() {
  # Close it
  echo "Closing $r_port on firewall... " >&2
  ssh "$ssh_opts" -t -S "$socket" xpo -- sudo iptables -D INPUT -p tcp --dport "$r_port" -j ACCEPT
  echo "done" >&2
  # Close the ssh connection
  ssh -S "$socket" -O exit xpo
}
trap clean EXIT

sleep infinity
