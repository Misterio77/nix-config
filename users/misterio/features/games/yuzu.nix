{ pkgs, features, lib, ... }: {
  home.packages = [ pkgs.yuzu-mainline ];

  home.persistence = lib.mkIf (builtins.elem "persistence" features) {
    "/data/games/misterio" = {
      allowOther = true;
      directories = [ "Games/Yuzu" ".config/yuzu" ".local/share/yuzu" ];
    };
  };
}
