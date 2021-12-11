{ pkgs }: {
  amdgpu-clocks = pkgs.callPackage ./amdgpu-clocks { };
  preferredplayer = pkgs.callPackage ./preferredplayer { };
  rgbdaemon = pkgs.callPackage ./rgbdaemon { };
  sistemer-bot = pkgs.callPackage ./sistemer-bot { };
  soundwire = pkgs.libsForQt5.callPackage ./soundwire { };
  wallpapers = pkgs.callPackage ./wallpapers { };
  zenity-askpass = pkgs.callPackage ./zenity-askpass { };

  setscheme = pkgs.callPackage ./setscheme { };
  setwallpaper = pkgs.callPackage ./setwallpaper { };

  setscheme-wofi =
    pkgs.callPackage ./setscheme-wofi { inherit (pkgs.gnome) zenity; };
  setwallpaper-wofi =
    pkgs.callPackage ./setwallpaper-wofi { inherit (pkgs.gnome) zenity; };

  shellcolord = pkgs.callPackage ./shellcolord { };

  # Experimental papermc version
  papermc-experimental = pkgs.callPackage ./papermc-experimental { };

  pass-wofi = pkgs.callPackage ./pass-wofi {
    pass = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  };

  alacritty-ligatures = pkgs.callPackage ./alacritty-ligatures { };
}
