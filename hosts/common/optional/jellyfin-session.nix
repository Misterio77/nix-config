{pkgs, lib, ...}: let
  jellyfin-kiosk = pkgs.writeShellScriptBin "jellyfin-kiosk" ''
    systemctl --user import-environment DISPLAY WAYLAND_DISPLAY
    env > ~/jellyfin-kiosk-env
    systemctl --user start jellyfin-kiosk-session.target
    ${lib.getExe pkgs.jellyfin-media-player} --tv
    systemctl --user stop jellyfin-kiosk-session.target
  '';

  jellyfin-kiosk-session =
    (pkgs.writeTextDir "share/wayland-sessions/jellyfin.desktop" ''
      [Desktop Entry]
      Name=Jellyfin
      Comment=A media platform
      Exec=${lib.getExe pkgs.cage} -s -m last -- ${lib.getExe jellyfin-kiosk}
      Type=Application
    '').overrideAttrs
      (_: {
        passthru.providedSessions = ["jellyfin"];
      });
in {
  nixpkgs.config.permittedInsecurePackages = ["qtwebengine-5.15.19"];

  services.displayManager.sessionPackages = [jellyfin-kiosk-session];

  systemd.user.targets.jellyfin-kiosk-session = {
    description = "Jellyfin session";
    bindsTo = ["graphical-session.target"];
    wants = ["graphical-session-pre.target"];
    after = ["graphical-session-pre.target"];
  };

  systemd.user.services.jellyfin-xbindkeys = {
    description = "Handle keybinds in Jellyfin session";
    wantedBy = ["jellyfin-kiosk-session.target"];
    partOf = ["jellyfin-kiosk-session.target"];
    after = ["jellyfin-kiosk-session.target"];
    path = with pkgs; [xbindkeys swayosd pulseaudio playerctl];

    script = ''
      xbindkeys --nodaemon --verbose --file ${pkgs.writeText "jellyfin-xbindkeysrc" ''
        # Volume control
        "swayosd-client --output-volume raise"
           XF86AudioRaiseVolume
        "swayosd-client --output-volume lower"
           XF86AudioLowerVolume
       "swayosd-client --output-volume mute-toggle"
           XF86AudioMute

        # Player control
        "swayosd-client --playerctl next"
           XF86AudioNext
        "swayosd-client --playerctl prev"
           XF86AudioPrev
        "swayosd-client --playerctl stop"
           XF86AudioStop
        "swayosd-client --playerctl play-pause"
           XF86AudioPlay
      ''}
    '';
  };

  systemd.user.services.jellyfin-swayosd = {
    description = "Show OSD in Jellyfin session";
    wantedBy = ["jellyfin-kiosk-session.target"];
    partOf = ["jellyfin-kiosk-session.target"];
    after = ["jellyfin-kiosk-session.target"];
    path = [pkgs.swayosd];
    script = "swayosd-server";
  };

}
