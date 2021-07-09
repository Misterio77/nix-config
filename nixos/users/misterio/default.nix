{ pkgs, ... }:

{
  imports = [
    ../../imports/impermanence/home-manager.nix
    ./modules/alacritty.nix
    ./modules/direnv.nix
    ./modules/git.nix
    ./modules/gpg-agent.nix
    ./modules/gtk.nix
    ./modules/rgbdaemon.nix
    ./modules/neofetch.nix
    ./modules/nvim.nix
    ./modules/pass.nix
    ./modules/qutebrowser.nix
    ./modules/starship.nix
    ./modules/sway.nix
    ./modules/zathura.nix
    ./modules/zsh.nix
    ./colorscheme.nix
  ];

  colorscheme = import ./schemes;

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Scripts
  home.file = { "bin".source = "/dotfiles/nixos/users/misterio/scripts"; };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    bottom
    discord
    fira
    fira-code
    glib
    inkscape
    playerctl
    pulseaudio
    spotify
    steam
    xdg-utils
  ];

  # Writable (persistent) data
  home.persistence."/data" = {
    directories = [
      "Documents"
      "Downloads"
      "Games"
      "Pictures"
      ".gnupg"
      ".config/Hero_Siege"
      ".local/share/Steam"
      ".local/share/Tabletop Simulator"
      ".local/share/password-store"
    ];
    allowOther = false;
  };
}
