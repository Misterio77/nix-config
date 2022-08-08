{ mkShell, nix, home-manager, git, gnupg, age, deploy-rs, sops, ... }:
mkShell {
  nativeBuildInputs = [
    nix
    home-manager
    git

    # Para deploy
    gnupg
    age
    deploy-rs
    sops
  ];
}
