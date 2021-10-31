{ pkgs, hostname, impermanence, nix-colors, nur, ... }:

{
  imports = [
    impermanence.nixosModules.home-manager.impermanence
    nix-colors.homeManagerModule
    ./firefox.nix
    ./git.nix
    # ./gnome-terminal.nix
    ./gtk.nix
    ./steam.nix
  ];

  programs.home-manager.enable = true;

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ nur.overlay ];
  };

  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [
    kdenlive
    libreoffice
    soundwire
  ];

  colorscheme = nix-colors.colorSchemes.dracula;

  home.persistence = {
    "/data/home/layla" = {
      directories = [
        "Documentos"
        "Downloads"
        "Imagens"
        "Vídeos"
        "Música"
        "Desktop"
        "Templates"
        "Public"
        "Jogos"
        "Livros"
        ".config/dconf"
      ];
      allowOther = true;
    };
  };
}
