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
        ".local/share/containers"
        ".local/share/flatpak"
        ".cache/flatpak"
      ];
      allowOther = true;
    };
  };
}
