{ pkgs, ... }: {
  imports = [
    ./nvim
    ./amfora.nix
    ./fish.nix
    ./git.nix
    ./neofetch.nix
    ./nix-index.nix
    ./ranger.nix
    ./starship.nix
    ./shellcolor.nix
    ./ssh.nix
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
