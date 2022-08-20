{ pkgs, ... }: {
  imports = [
    ./amfora.nix
    ./bash.nix
    ./bat.nix
    ./fish.nix
    ./git.nix
    ./gpg.nix
    ./nix-index.nix
    ./nvim
    ./pfetch.nix
    ./ranger.nix
    ./screen.nix
    ./shellcolor.nix
    ./ssh.nix
    ./starship.nix
    ./xpo.nix
  ];
  home.packages = with pkgs; [
    cachix # For managing my binary cache
    comma # Install and run programs by sticking a , before them
    distrobox # Nice escape hatch, integrates docker images with my environment

    bottom # System viewer
    ncdu # TUI disk usage
    exa # Better ls
    ripgrep # Better grep
    fd # Better find
    httpie # Better curl
    jq # JSON pretty printer and manipulator
    trekscii # Cute startrek cli printer

    sops # Deployment secrets tool
    nvd nix-diff # Check derivation differences
    rnix-lsp # Nix LSP
    nixfmt # Nix formatter
    deadnix # Nix dead code locator
    statix # Nix linter
    haskellPackages.nix-derivation # Inspecting .drv's
  ];
}
