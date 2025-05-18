{lib, config, ...}: let
  hyprland = lib.getExe config.wayland.windowManager.hyprland.package;
in {
  programs.zsh.loginExtra = lib.mkBefore ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      exec ${hyprland} &> /dev/null
    fi
  '';
  programs.fish.loginShellInit = lib.mkBefore ''
    if test (tty) = /dev/tty1
      exec ${hyprland} &> /dev/null
    end
  '';
  programs.bash.profileExtra = lib.mkBefore ''
    if [[ "$(tty)" == /dev/tty1 ]]; then
      exec ${hyprland} &> /dev/null
    fi
  '';
}
