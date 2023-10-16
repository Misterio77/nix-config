{ pkgs, lib, config, ... }:
let
  steam-with-pkgs = pkgs.steam.override {
    extraPkgs = pkgs: with pkgs; [
      xorg.libXcursor
      xorg.libXi
      xorg.libXinerama
      xorg.libXScrnSaver
      libpng
      libpulseaudio
      libvorbis
      stdenv.cc.cc.lib
      libkrb5
      keyutils
      gamescope
      mangohud
    ];
  };

  monitor = lib.head (lib.filter (m: m.primary) config.monitors);
  steam-session = pkgs.writeTextDir "share/wayland-sessions/steam-sesson.desktop" /* ini */ ''
    [Desktop Entry]
    Name=Steam Session
    Exec=${pkgs.gamescope}/bin/gamescope -W ${toString monitor.width} -H ${toString monitor.height} -O ${monitor.name} -e -- steam -gamepadui
    Type=Application
  '';
in
{
  home.packages = with pkgs; [
    steam-with-pkgs
    steam-session
    gamescope
    mangohud
    protontricks
  ];
  home.persistence = {
    "/persist/home/misterio" = {
      allowOther = true;
      directories = [
        ".factorio"
        ".config/Hero_Siege"
        ".config/unity3d/Berserk Games/Tabletop Simulator"
        ".config/unity3d/IronGate/Valheim"
        ".local/share/Tabletop Simulator"
        ".local/share/Paradox Interactive"
        ".paradoxlauncher"
        {
          # A couple of games don't play well with bindfs
          directory = ".local/share/Steam";
          method = "symlink";
        }
      ];
    };
  };
}
