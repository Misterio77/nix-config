{ pkgs, lib, ... }: {
  home.packages = [ pkgs.yuzu-mainline ];

  home.persistence = {
    "/persist/home/misterio" = {
      allowOther = true;
      directories = [ ".config/yuzu" ".local/share/yuzu" ];
    };
  };
}
