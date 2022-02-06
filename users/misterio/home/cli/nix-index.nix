{ lib, persistence, ... }: {
  programs.nix-index.enable = true;

  home.persistence = lib.mkIf persistence {
    "/data/home/misterio".directories = [ ".cache/nix-index" ];
  };
}
