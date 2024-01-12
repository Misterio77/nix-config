{ pkgs ? import <nixpkgs> { } }: rec {

  # Packages with an actual source
  rgbdaemon = pkgs.callPackage ./rgbdaemon { };
  shellcolord = pkgs.callPackage ./shellcolord { };
  trekscii = pkgs.callPackage ./trekscii { };

  # Personal scripts
  nix-inspect = pkgs.callPackage ./nix-inspect { };
  minicava = pkgs.callPackage ./minicava { };
  pass-wofi = pkgs.callPackage ./pass-wofi { };
  primary-xwayland = pkgs.callPackage ./primary-xwayland { };
  wl-mirror-pick = pkgs.callPackage ./wl-mirror-pick { };
  lyrics = pkgs.python3Packages.callPackage ./lyrics { };
  xpo = pkgs.callPackage ./xpo { };
  tly = pkgs.callPackage ./tly { };
  hyprslurp = pkgs.callPackage ./hyprslurp { };

  # My slightly customized plymouth theme, just makes the blue outline white
  plymouth-spinner-monochrome = pkgs.callPackage ./plymouth-spinner-monochrome { };

  # My wallpaper collection
  wallpapers = pkgs.callPackage ./wallpapers { };
}
