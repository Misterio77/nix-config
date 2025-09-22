{pkgs, lib, ...}: let
  sessionFile =
    (pkgs.writeTextDir "share/wayland-sessions/jellyfin-kiosk.desktop" ''
      [Desktop Entry]
      Name=Jellyfin
      Comment=A media platform
      Exec=${lib.getExe pkgs.cage} -s -m last -- ${lib.getExe pkgs.firefox} -kiosk https://media.m7.rs
      Type=Application
    '').overrideAttrs
      (_: {
        passthru.providedSessions = [ "jellyfin-kiosk" ];
      });
in {
  services.displayManager.sessionPackages = [sessionFile];
}
