{ pkgs, persistence, lib, ... }: {
  home.packages = [ pkgs.yuzu-mainline ];

  home.persistence = lib.mkIf persistence {
    "/data/games/misterio" = {
      allowOther = true;
      directories = [ "Games/Yuzu" ".config/yuzu" ".local/share/yuzu" ];
    };
  };
}
