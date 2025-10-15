{pkgs, ...}: {
  imports = [
    ./alacritty.nix
    ./cliphist.nix
    ./clip-notify.nix
    ./gammastep.nix
    ./mako.nix
    ./qutebrowser.nix
    ./waybar.nix
    ./wofi.nix
    ./zathura.nix
    ./imv.nix
    ./waypipe.nix
    ./swayosd.nix
  ];

  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    wf-recorder
    wl-clipboard
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };

  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-wlr];
}
