{
  config,
  ...
}: {
  # Temporarily disabled while I wait for nixpkgs to package a fork (e.g. suyu)
  # home.packages = [ pkgs.yuzu-mainline ];

  home.persistence = {
    "/persist/${config.home.homeDirectory}" = {
      allowOther = true;
      directories = [
        ".config/yuzu"
        ".local/share/yuzu"
      ];
    };
  };
}
