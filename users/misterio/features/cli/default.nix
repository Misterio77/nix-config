{ pkgs, ... }: {
  imports = [
    ./nvim
    ./amfora.nix
    ./bat.nix
    ./fish.nix
    ./git.nix
    ./neofetch.nix
    ./nix-index.nix
    ./pmis.nix
    ./ranger.nix
    ./shellcolor.nix
    ./ssh.nix
    ./starship.nix
  ];
  home.packages = with pkgs; [
    # Cli
    nur.repos.misterio.comma
    bottom
    cachix
    exa
    ncdu
    rnix-lsp
  ];
}
