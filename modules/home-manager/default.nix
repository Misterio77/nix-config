{
  fonts = import ./fonts.nix;
  monitors = import ./monitors.nix;
  oama = import ./oama.nix;
  pass-secret-service = import ./pass-secret-service.nix;
  wallpaper = import ./wallpaper.nix;
  xpo = import ./xpo.nix;
  colors = import ./colors.nix;
  calendar-changes = import ./calendar-changes.nix;
  vdirsyncer = import ./vdirsyncer.nix;
  export-sessions = import ./export-sessions.nix;
}
