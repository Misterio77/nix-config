{ pkgs, ... }:

{
  imports = [
    ../../imports/impermanence/home-manager.nix
    ./programs/alacritty.nix
    ./programs/direnv.nix
    ./programs/flavours.nix
    ./programs/git.nix
    ./programs/gpg-agent.nix
    ./programs/neofetch.nix
    ./programs/nvim.nix
    ./programs/pass.nix
    ./programs/qutebrowser.nix
    ./programs/starship.nix
    ./programs/sway.nix
    ./programs/zathura.nix
    ./programs/zsh.nix
  ];

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Scripts
  home.file = { "bin".source = "/dotfiles/nixos/users/misterio/scripts"; };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    glib
    bottom
    discord
    fira
    fira-code
    inkscape
    playerctl
    pulseaudio
    spotify
    steam
    xdg-utils
  ];

  gtk = {
    enable = true;
    font = {
      name = "Fira Sans";
      size = 12;
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };
    theme = {
      name = "FlatColor";
    };
  };

  home.file.".themes/FlatColor" = {
    source = "/dotfiles/nixos/users/misterio/themes/FlatColor";
  };

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
