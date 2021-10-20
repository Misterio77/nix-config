{ pkgs, ... }: {
  home.packages = [ pkgs.yuzu-mainline ];

  home.persistence = {
    "/data/games/misterio" = {
      allowOther = true;
      directories = [ "Games/Yuzu" ".config/yuzu" ".local/share/yuzu" ];
    };
  };
}
