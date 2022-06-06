{ pkgs, persistence, lib, ... }: {
  home.packages = [ pkgs.yuzu-mainline ];

  home.persistence = lib.mkIf persistence {
    "/persist/games/misterio" = {
      allowOther = true;
      directories = [ "Games/Yuzu" ".config/yuzu" ".local/share/yuzu" ];
    };
  };
}
