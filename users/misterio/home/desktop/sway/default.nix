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
    imv
    mimeo
    slurp
    wf-recorder
    wl-clipboard
    wl-mirror
    wofi
    xdg-utils
    xdragon
    ydotool
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = true;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };

}
