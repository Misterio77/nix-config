# Shell for bootstrapping flake-enabled nix and other tooling
{ pkgs ? let
    # If pkgs is not defined, instanciate nixpkgs from locked commit
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
  import nixpkgs { overlays = [ ]; }
, ...
}: pkgs.mkShell {
  NIX_CONFIG = "experimental-features = nix-command flakes";
  nativeBuildInputs = with pkgs; [
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
