{ lib, persistence, ... }: {
  programs.nix-index.enable = true;

  home.persistence = lib.mkIf persistence {
    "/persist/home/misterio".directories = [ ".cache/nix-index" ];
  };
}
