{pkgs, lib, ...}: let
  sway-kiosk = command: let
    config = pkgs.writeText "kiosk.config" ''
      exec swayosd-server
      # Volume control
      bindsym XF86AudioRaiseVolume exec swayosd-client --output-volume raise
      bindsym XF86AudioLowerVolume exec swayosd-client --output-volume lower
      bindsym XF86AudioMute        exec swayosd-client --output-volume mute-toggle
      # Player control
      bindsym XF86AudioNext    exec swayosd-client --playerctl next
      bindsym XF86AudioPrev    exec swayosd-client --playerctl prev
      bindsym XF86AudioStop    exec swayosd-client --playerctl stop
      bindsym XF86AudioPlay    exec swayosd-client --playerctl play-pause
      bindsym XF86VoiceCommand exec swayosd-client --playerctl play-pause

      exec '${command}; swaymsg exit'
    '';
  in pkgs.writeShellApplication {
    name = "sway-kiosk";
    runtimeInputs = with pkgs; [sway swayosd pulseaudio playerctl];
    text = "sway --config ${config}";
  };

  sessionFile =
    (pkgs.writeTextDir "share/wayland-sessions/jellyfin-kiosk.desktop" ''
      [Desktop Entry]
      Name=Jellyfin
      Comment=A media platform
      Exec=${sway-kiosk "${lib.getExe pkgs.jellyfin-media-player} --tv"}
      Type=Application
    '').overrideAttrs
      (_: {
        passthru.providedSessions = [ "jellyfin-kiosk" ];
      });
in {
  services.displayManager.sessionPackages = [sessionFile];
  nixpkgs.config.permittedInsecurePackages = ["qtwebengine-5.15.19"];
}
