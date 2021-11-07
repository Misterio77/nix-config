{ pkgs, features, lib, ... }:

{
  home.packages = with pkgs; [ slack ];

  home.persistence = lib.mkIf (builtins.elem "persistence" features) {
    "/data/home/misterio".directories = [ ".config/Slack" ];
  };
}
