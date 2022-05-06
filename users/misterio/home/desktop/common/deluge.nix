{ pkgs, ... }: {
  home.packages = with pkgs; [ deluge ];
}
