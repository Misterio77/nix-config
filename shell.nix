{ mkShell, nix, home-manager, git, gnupg, age, deploy-rs, sops, ... }:
pkgs.mkShell {
  nativeBuildInputs = [
    nix
    home-manager
    git

    # Para deploy
    gnupg
    age
    deploy-rs.deploy-rs
    sops
  ];
}
