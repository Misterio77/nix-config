{ pkgs, ... }: {
  imports = [
    ./nvim
    ./amfora.nix
    ./bat.nix
    ./fish.nix
    ./git.nix
    ./neofetch.nix
    ./nix-index.nix
    ./ranger.nix
    ./screen.nix
    ./shellcolor.nix
    ./ssh.nix
    ./starship.nix
  ];
  home.packages = with pkgs; [
    # CLI Utils
    comma
    bottom
    cachix
    exa
    ncdu
    ripgrep
    # Nix tooling
    rnix-lsp
    nixfmt
    deadnix
  ];
}
