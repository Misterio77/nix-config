{ pkgs, ... }:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    nix
    home-manager
    git

    # Para deploy
    ssh-to-pgp
    gnupg
    age
    deploy-rs.deploy-rs
    sops
  ];
}
