{ pkgs, ... }:

{
  imports = [
    ../../imports/impermanence/home-manager.nix
    ./programs/alacritty.nix
    ./programs/direnv.nix
    ./programs/git.nix
    ./programs/gpg-agent.nix
    ./programs/nvim.nix
    ./programs/starship.nix
    ./programs/sway.nix
    ./programs/zathura.nix
    ./programs/zsh.nix
  ];

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    fira
    fira-code
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    (pass.withExtensions (ext: with ext; [ pass-otp ]))
    flavours
    steam
    qutebrowser
    bottom
    jq
    pulseaudio
    playerctl
    glxinfo
    neofetch
    inkscape
    spotify
    ];

  # Writable (persistent) data
  home.persistence."/data" = {
    directories = [
      "Documents"
      "Downloads"
      "Games"
      "Pictures"
      ".local/share/Steam"
      ".password-store"
      ".gnupg"
      ".local/share/Tabletop Simulator"
      ".config/Hero_Siege"
    ];
    allowOther = false;
  };

  # Read-only data
  # Configuration files
  xdg.configFile = {
    "flavours/config.toml".source = "/dotfiles/configs/flavours.toml";
    "qutebrowser/config.py".source = "/dotfiles/configs/qutebrowser.py";
    "alacritty/alacritty.yml".source = "/dotfiles/configs/alacritty.yml";
    "neofetch/config.conf".source = "/dotfiles/configs/neofetch.conf";
  };
  # Data files
  xdg.dataFile = { "flavours/base16".source = "/dotfiles/configs/flavours"; };
  # Scripts
  home.file = { "bin".source = "/dotfiles/scripts"; };
}
