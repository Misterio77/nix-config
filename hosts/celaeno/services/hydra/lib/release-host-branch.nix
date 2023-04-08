{ sshKeyFile, writeShellApplication, jq, git, ... }: writeShellApplication {
  name = "release-host-branch";
  runtimeInputs = [ jq git ];
  text = ''
    job="$(jq -r '.job' < "$HYDRA_JSON")"
    outpath="$(jq -r '.outputs[] | select(.name == "out") | .path' < "$HYDRA_JSON")"
    echo "Running for $job, built $outpath"

    if [[ "$job" != "hosts."* ]]; then
        echo "Not a NixOS Host job, skipping."
        exit 0
    fi

    host="''${job##*.}"
    commit="$(jq -r '.flakes[] | select(.from.id == "self") | .to.rev' "''${outpath}/etc/nix/registry.json")"
    echo "System is $host at $commit"

    # Start ssh-agent if nescessary
    ssh-add || eval "$(ssh-agent)"
    ssh-add ${sshKeyFile}
    export GIT_SSH_COMMAND="ssh -A" # Forward agent

    repo="/tmp/hydra/nix-config"

    # Check if repo already exists
    if git -C "$repo" rev-parse --git-dir &> /dev/null; then
      git -C "$repo" fetch origin
    else
      mkdir -p "$repo"
      git clone --bare git@m7.rs:nix-config "$repo"
    fi

    git -C "$repo" branch -f "release-$host" "$commit"
    git -C "$repo" push -f origin "release-$host" -o "release-$host"
  '';
}
