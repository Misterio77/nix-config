{ config, pkgs, system, inputs, ... }:

{
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
    inputs.nix-colors.homeManagerModule

    ./firefox.nix
    ./git.nix
    # ./gnome-terminal.nix
    ./gtk.nix
    ./steam.nix
  ];

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [ kdenlive libreoffice soundwireserver pavucontrol chromium ];

  colorscheme = inputs.nix-colors.colorSchemes.dracula;

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
        ".config/StardewValley"
        ".config/chromium"
      ];
      allowOther = true;
    };
  };
}
