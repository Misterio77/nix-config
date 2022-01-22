{ lib, features, inputs, ... }: {
  imports = [ inputs.pmis.homeManagerModule ];

  programs.pmis.enable = true;

  home.persistence = lib.mkIf (builtins.elem "persistence" features) {
    "/data/home/misterio".directories = [ ".config/pmis" ];
  };
}
