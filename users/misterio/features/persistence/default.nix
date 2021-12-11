{ impermanence, ... }: {
  imports = [ impermanence.nixosModules.home-manager.impermanence ];

  home.persistence = {
    "/data/home/misterio" = {
      directories = [
        "Documents"
        "Downloads"
        "Pictures"
        "Videos"
        ".local/share/containers"
      ];
      allowOther = true;
    };
  };
}
