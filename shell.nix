{ pkgs ? import <nixpkgs> { } }:

with pkgs;
mkShell {
  buildInputs = [ git nix-zsh-completions nixfmt ];
  shellHook = ''
    export FLAKE="$(pwd)"
  '';
}
