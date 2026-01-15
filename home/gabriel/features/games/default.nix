{pkgs, config, ...}: {
  imports = [
    ./steam.nix
    ./prism-launcher.nix
    ./runescape.nix
    ./hytale.nix
  ];
  home = {
    packages = with pkgs; [gamescope];
    persistence = {
      "/persist".directories = [
        "Games"
        ".config/unity3d" # Unity game saves
      ];
    };
  };
}
