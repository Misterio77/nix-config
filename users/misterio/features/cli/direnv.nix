{ lib, features, ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.persistence = lib.mkIf (builtins.elem "persistence" features) {
    "/data/home/misterio".directories = [ ".local/share/direnv" ];
  };
}
