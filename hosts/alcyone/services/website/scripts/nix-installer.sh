#!/bin/sh

arch="$(uname -m)"
job="https://hydra.nixos.org/job/nix/master/buildStatic.$arch-linux/latest/download-by-type/file/binary-dist"
echo "Downloading from: $job"

mkdir -p "$HOME/.local/bin"
curl -L "$job" -o "$HOME/.local/bin/nix"
chmod +x "$HOME/.local/bin/nix"

mkdir -p "$HOME/.config/nix"
echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
