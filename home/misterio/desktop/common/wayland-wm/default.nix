{ pkgs, ... }:
{
  imports = [
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

  home.packages = with pkgs; [
    imv
    mimeo
    slurp
    wf-recorder
    wl-clipboard
    wl-mirror
    wl-mirror-pick
    ydotool
    primary-xwayland
    pulseaudio
    lyrics
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = true;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };
}
