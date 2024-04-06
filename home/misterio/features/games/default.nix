{ pkgs, ... }:
{
  imports = [
    ./lutris.nix
    ./steam.nix
    ./prism-launcher.nix
    ./runescape.nix
  ];
  home = {
    packages = with pkgs; [ gamescope ];
    persistence = {
      "/persist/home/misterio" = {
        allowOther = true;
        directories = [
          {
            # Use symlink, as games may be IO-heavy
            directory = "Games";
            method = "symlink";
          }
        ];
      };
    };
  };
}
