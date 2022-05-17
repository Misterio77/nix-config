{ pkgs }: pkgs.poetry2nix.mkPoetryApplication {
  projectDir = ./.;
  overrides = [ pkgs.poetry2nix.defaultPoetryOverrides ];
}
