{ lib, features, ... }: {
  programs.nix-index.enable = true;

  home.persistence = lib.mkIf (builtins.elem "persistence" features) {
    "/data/home/misterio".directories = [ ".cache/nix-index" ];
  };
}
