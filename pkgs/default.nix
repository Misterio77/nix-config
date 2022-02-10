{ pkgs }: {
  wallpapers = pkgs.callPackage ./wallpapers { };

  shellcolord = pkgs.callPackage ./shellcolord { };
  rgbdaemon = pkgs.callPackage ./rgbdaemon { };

  preferredplayer = pkgs.callPackage ./preferredplayer { };

  setscheme = pkgs.callPackage ./setscheme { };
  setwallpaper = pkgs.callPackage ./setwallpaper { };

  pass-wofi = pkgs.callPackage ./pass-wofi { };

  setscheme-wofi =
    pkgs.callPackage ./setscheme-wofi { inherit (pkgs.gnome) zenity; };
  setwallpaper-wofi =
    pkgs.callPackage ./setwallpaper-wofi { inherit (pkgs.gnome) zenity; };

  alacritty-ligatures = pkgs.callPackage ./alacritty-ligatures { };

  clematis = pkgs.callPackage ./clematis { };
}
