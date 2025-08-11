{pkgs, config, ...}: {
  imports = [
    ./steam.nix
    ./prism-launcher.nix
    ./runescape.nix
  ];
  home = {
    packages = with pkgs; [gamescope];
    persistence = {
      "/persist".directories = [
        "Games"
      ];
    };
  };
}
