{ pkgs, ... }:
{
  imports = [
    ./nvim
    ./direnv.nix
    ./fish.nix
    ./git.nix
    ./neofetch.nix
    ./nix-index.nix
    ./ranger.nix
    ./starship.nix
  ];
  home.packages = with pkgs; [
    # Cli
    pkgs.nur.repos.misterio.comma
    bottom
    cachix
    exa
    ncdu
    rnix-lsp
  ];
}
