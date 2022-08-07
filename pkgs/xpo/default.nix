# Exposes a port through SSH
# xpo [local port] [remote host]

{ writeShellApplication, openssh  }: writeShellApplication {
  name = "xpo";
  runtimeInputs = [ openssh ];

  text = /* bash */ ''
    socket="''${XDG_RUNTIME_DIR:-/run/user/''${UID:-1000}}/xpo-$BASHPID.sock"
    server="''${2:-$XPO_SERVER}"
    user="''${XPO_SSH_USER:-$USER}"
    l_port="''${1:-8080}"

    # Open master ssh connection
    ssh -f -TNA -MS "$socket" "$user@$server"

    echo "Forwarding :$l_port" >&2

    # Try to detect what is being forwarded, for clickable link
    if [ "$l_port" -ge "8080" ] && [ "$l_port" -le "8089" ]; then
      proto="http://"
    elif [ "$l_port" -eq "8443" ]; then
      proto="https://"
    elif [ "$l_port" -eq "1965" ]; then
      proto="gemini://"
    else
      proto=""
    fi

    # Forward port and record it
    r_port="$(ssh -S "$socket" -O forward -R "*:0:localhost:$l_port" f)"
    echo "$proto$server:$r_port"

    # Open it through iptables
    echo -n "Opening $r_port on firewall... " >&2
    ssh -AS "$socket" f -- sudo iptables -I INPUT -p tcp --dport "$r_port" -j ACCEPT
    echo "done" >&2

    clean() {
      # Close it
      echo "Closing $r_port on firewall... " >&2
      ssh -AS "$socket" f -- sudo iptables -D INPUT -p tcp --dport "$r_port" -j ACCEPT
      echo "done" >&2
      # Close the ssh connection
      ssh -S "$socket" -O exit f
    }
    trap clean EXIT

    sleep infinity
  '';
}
