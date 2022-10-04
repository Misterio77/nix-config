#!/usr/bin/env bash
export NIX_SSHOPTS="-A"

build_remote=false

if [ "$#" -eq 0 ]; then
    echo "No hosts to deploy"
    exit 2
fi

hosts="$1"
shift

for host in ${hosts//,/ }; do
    nixos-rebuild --flake .\#$host switch --target-host $host --use-remote-sudo $@
done
