{
  programs = {
    fish.loginShellInit = /* fish */ ''
      if test (tty) = "/dev/tty1"
        exec Hyprland &> /dev/null
      end
    '';
    zsh.loginExtra = /* bash */ ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland &> /dev/null
      fi
    '';
    zsh.profileExtra = /* bash */ ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec Hyprland &> /dev/null
      fi
    '';
  };
}
