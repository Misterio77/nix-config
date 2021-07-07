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

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    bottom
    discord
    fira
    fira-code
    inkscape
    nixfmt
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
  };

  # Read-only data
  # Data files
  xdg.dataFile = { "flavours/base16".source = "/dotfiles/configs/flavours"; };
  # Scripts
  home.file = { "bin".source = "/dotfiles/scripts"; };
}
