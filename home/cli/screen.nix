{ pkgs, ... }: {
  home.packages = [ pkgs.screen ];
  home.file.".screenrc".text = ''
    startup_message off
    defbce on
    setenv TERM xterm-256color
  '';
}
