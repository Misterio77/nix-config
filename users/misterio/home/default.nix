{ pkgs, ... }:

let
  colors = import ../../../colors.nix;
in {
  imports = [
    ./alacritty.nix
    ./direnv.nix
    ./fzf.nix
    ./git.nix
    ./gpg-agent.nix
    ./gtk.nix
    ./qt.nix
    ./rgbdaemon.nix
    ./neofetch.nix
    ./nvim.nix
    ./pass.nix
    ./qutebrowser.nix
    ./starship.nix
    ./sway.nix
    ./waybar.nix
    ./zathura.nix
    ./zsh.nix
    ../../../modules/colorscheme.nix
    ../../../modules/wallpaper.nix
    ../../../modules/ethminer.nix
  ];

  colorscheme = colors.pasque;
  wallpaper.generate = true;

  home.packages = with pkgs; [
    firefox-bin
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    bottom
    comma
    discord
    dragon-drop
    exa
    fira
    fira-code
    lm_sensors
    lutris
    multimc
    osu-lazer
    pinentry-gnome
    setscheme
    spotify
    steam
    trash-cli
    xdg-utils
    vulkan-tools
  ];

  fonts.fontconfig.enable = true;

  # Writable (persistent) data
  home.persistence."/data/home/misterio" = {
     directories = [
       "Documents"
       "Downloads"
       "Games"
       "Pictures"
       ".gnupg"
       ".config/Hero_Siege"
       ".config/lutris"
       ".local/share/lutris"
       ".local/share/password-store"
       ".local/share/Steam"
       ".local/share/multimc"
       ".local/share/osu"
       ".local/share/Tabletop Simulator"
       #".local/share/direnv"
     ];
     allowOther = false;
   };

  services.ethminer = {
    enable = true;
    wallet = "0x16EeE21f85c06D3B983533b32Eef82d963d24f9a";
    pool = "eth-br.flexpool.io";
    port = 5555;
    rig = "misterio";
  };
}
