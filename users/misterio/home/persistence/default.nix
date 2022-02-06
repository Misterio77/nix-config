{ inputs, ... }: {
  imports = [ inputs.impermanence.nixosModules.home-manager.impermanence ];

  home.persistence = {
    "/persist/home/misterio" = {
      directories = [
        "Documents"
        "Downloads"
        "Pictures"
        "Videos"
      ];
      allowOther = true;
    };
  };
}
