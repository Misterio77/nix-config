{ pkgs, lib, ... }:
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
    ];
  };
in
{
  home.packages = with pkgs; [
    steam-with-pkgs
    gamescope
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
