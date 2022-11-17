{ pkgs, ... }: {
  imports = [
    ./lutris.nix
    ./steam.nix
    ./prism-launcher.nix
  ];
  home.packages = with pkgs; [ gamescope ];
}
