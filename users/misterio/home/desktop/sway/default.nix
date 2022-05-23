{ pkgs, ... }: {
  imports = [
    ../common
    ./gammastep.nix
    ./kitty.nix
    ./mako.nix
    ./qt.nix
    ./sway.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
    ./wofi.nix
  ];

  xdg.mimeApps.enable = true;

  home.packages = with pkgs; [
    mimeo
    imv
    wofi
    xdg-utils
    ydotool
    wl-clipboard
    wf-recorder
    slurp
    xdragon
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = true;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };

}
