{ pkgs, ... }: {
  imports = [
    ./lutris.nix
    ./factorio.nix
    ./steam.nix
    ./prism-launcher.nix
  ];
  home.packages = with pkgs; [ gamescope ];
}
