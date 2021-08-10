{ pkgs, impermanence, ... }:

{
  imports = [
    #"${impermanence}/home-manager.nix"
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

  home.username = "misterio";
  home.homeDirectory = "/home/misterio";

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    asciinema
    bottom
    cbonsai
    clinfo
    cmatrix
    delta
    discord
    dragon-drop
    exa
    fira
    fira-code
    glib
    gnome.zenity
    gsettings-desktop-schemas
    imv
    lm_sensors
    lutris
    multimc
    openssl
    osu-lazer
    pinentry-gnome
    pipes
    spotify
    steam
    #gamescope
    trash-cli
    vulkan-tools
    xdg-utils
  ];

  fonts.fontconfig.enable = true;

  # Writable (persistent) data
  /* home.persistence."/data/home/misterio" = {
       directories = [
         "Documents"
         "Downloads"
         "Games"
         "Pictures"
         ".gnupg"
         ".local/share/password-store"
         ".local/share/Steam"
         ".local/share/multimc"
         ".local/share/lutris"
         ".config/lutris"
         ".local/share/osu"
         ".local/share/Tabletop Simulator"
         ".config/Hero_Siege"
       ];
       allowOther = false;
     };
  */

  colorscheme = import ../../../colors/paraiso.nix;
  wallpaper.generate = true;
  #wallpaper.path = "/dotfiles/users/misterio/Wallpapers/astronaut-minimalism.png";

  services.ethminer = {
    enable = false;
    wallet = "0x16EeE21f85c06D3B983533b32Eef82d963d24f9a";
    pool = "eth-br.flexpool.io";
    port = 5555;
    rig = "misterio";
  };
}
