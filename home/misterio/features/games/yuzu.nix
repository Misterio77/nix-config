{ pkgs, lib, ... }:
{
  # Temporarily disabled while I wait for nixpkgs to package a fork (e.g. suyu)
  # home.packages = [ pkgs.yuzu-mainline ];

  home.persistence = {
    "/persist/home/misterio" = {
      allowOther = true;
      directories = [
        ".config/yuzu"
        ".local/share/yuzu"
      ];
    };
  };
}
