{
  programs.nix-index.enable = true;
  home.persistence."/data/home/misterio".directories = [
    ".cache/nix-index"
  ];
}
