{ inputs, ... }: {
  imports = [ inputs.impermanence.nixosModules.home-manager.impermanence ];

  home.persistence = {
    "/data/home/misterio" = {
      directories = [
        "Documents"
        "Downloads"
        "Pictures"
        "Videos"
        ".cabal"
        ".cargo"
      ];
      allowOther = true;
    };
  };
}
