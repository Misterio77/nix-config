{ pkgs, ... }: {
  imports = [
    ./kitty.nix
    ./discord.nix
    ./font.nix
    ./gammastep.nix
    ./gtk.nix
    ./kdeconnect.nix
    ./mako.nix
    ./qt.nix
    ./qutebrowser.nix
    ./sublime-music.nix
    ./sway.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
    ./wofi.nix
    ./zathura.nix
  ];

  xdg.mimeApps.enable = true;

  home.packages = with pkgs; [
    mimeo
    deluge
    xdragon
    imv
    pavucontrol
    wofi
    xdg-utils
    ydotool
    wl-clipboard
    wf-recorder
    slurp
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = true;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };

}
