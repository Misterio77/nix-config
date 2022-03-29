{ pkgs }: {
  wallpapers = pkgs.callPackage ./wallpapers { };

  shellcolord = pkgs.callPackage ./shellcolord { };
  rgbdaemon = pkgs.callPackage ./rgbdaemon { };

  preferredplayer = pkgs.callPackage ./preferredplayer { };

  pass-wofi = pkgs.callPackage ./pass-wofi { };

  alacritty-ligatures = pkgs.callPackage ./alacritty-ligatures { };

  clematis = pkgs.callPackage ./clematis { };

  photoprism = pkgs.callPackage ./photoprism { };
}
