{ pkgs ? import <nixpkgs> { } }: {
  modules = import ./modules/nixos;
  homeManagerModules = import ./modules/home-manager;
}
  # Import packages to top-level
  // (import ./pkgs { inherit pkgs; })
