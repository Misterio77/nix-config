{ pkgs, lib, ... }: {
  home.packages = [ pkgs.yuzu-mainline ];

  home.persistence = {
    "/persist/games/misterio" = {
      allowOther = true;
      directories = [ "Games/Yuzu" ".config/yuzu" ".local/share/yuzu" ];
    };
  };
}
