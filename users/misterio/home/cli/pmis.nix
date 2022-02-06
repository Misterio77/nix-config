{ lib, persistence, inputs, ... }: {
  imports = [ inputs.pmis.homeManagerModule ];

  programs.pmis.enable = true;

  home.persistence = lib.mkIf persistence {
    "/persist/home/misterio".directories = [ ".config/pmis" ];
  };
}
