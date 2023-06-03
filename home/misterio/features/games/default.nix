{ pkgs, ... }: {
  imports = [
    ./lutris.nix
    ./steam.nix
    ./prism-launcher.nix
    ./runescape.nix
  ];
  home.packages = with pkgs; [ gamescope ];
}
