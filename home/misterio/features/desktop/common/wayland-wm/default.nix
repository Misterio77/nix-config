{pkgs, ...}: {
  imports = [
    ./hyprland-vnc.nix
    ./gammastep.nix
    ./kitty.nix
    ./mako.nix
    ./qutebrowser.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
    ./wofi.nix
    ./zathura.nix
  ];

  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    grim
    imv
    mimeo
    primary-xwayland
    pulseaudio
    slurp
    waypipe
    wf-recorder
    wl-clipboard
    wl-mirror
    wl-mirror-pick
    xdg-utils
    ydotool
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };

  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-wlr];
}
