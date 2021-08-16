{ pkgs, ... }:

let
  colors = import ../../../colors.nix;
in {
  imports = [
    ../../../modules/colorscheme.nix
    ../../../modules/ethminer.nix
    ../../../modules/wallpaper.nix
    ./alacritty.nix
    ./direnv.nix
    ./ethminer.nix
    ./fish.nix
    ./fzf.nix
    ./git.nix
    ./gpg-agent.nix
    ./gtk.nix
    ./neofetch.nix
    ./nix-index.nix
    ./nvim.nix
    ./pass.nix
    ./qt.nix
    ./qutebrowser.nix
    ./rgbdaemon.nix
    ./starship.nix
    ./sway.nix
    ./waybar.nix
    ./zathura.nix
  ];

  colorscheme = colors.paraiso;
  wallpaper.generate = true;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    bottom
    comma
    discord
    dragon-drop
    exa
    fira
    fira-code
    firefox-bin
    lm_sensors
    lutris
    multimc
    nodePackages.speed-test
    osu-lazer
    pinentry-gnome
    setscheme
    spotify
    steam
    trash-cli
    vulkan-tools
    xdg-utils
  ];

  fonts.fontconfig.enable = true;

  # Writable (persistent) data
  home.persistence."/data/home/misterio" = {
     directories = [
       "Documents"
       "Downloads"
       "Games"
       "Pictures"
       ".cache/nix-index"
       ".config/Hero_Siege"
       ".config/lutris"
       ".gnupg"
       ".local/share/Steam"
       ".local/share/Tabletop Simulator"
       ".local/share/lutris"
       ".local/share/multimc"
       ".local/share/osu"
       ".local/share/password-store"
       ".local/share/direnv"
     ];
     files = [
       ".steam/steam.token"
       ".steam/registry.vdf"
     ];
     allowOther = false;
   };
}
