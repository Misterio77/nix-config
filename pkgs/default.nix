{ pkgs }: {
  wallpapers = pkgs.callPackage ./wallpapers { };

  shellcolord = pkgs.callPackage ./shellcolord { };
  rgbdaemon = pkgs.callPackage ./rgbdaemon { };
  sistemer-bot = pkgs.callPackage ./sistemer-bot { };

  preferredplayer = pkgs.callPackage ./preferredplayer { };
  zenity-askpass = pkgs.callPackage ./zenity-askpass { };

  setscheme = pkgs.callPackage ./setscheme { };
  setwallpaper = pkgs.callPackage ./setwallpaper { };

  pass-wofi = pkgs.callPackage ./pass-wofi {
    pass = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  };

  setscheme-wofi =
    pkgs.callPackage ./setscheme-wofi { inherit (pkgs.gnome) zenity; };
  setwallpaper-wofi =
    pkgs.callPackage ./setwallpaper-wofi { inherit (pkgs.gnome) zenity; };


  alacritty-ligatures = pkgs.callPackage ./alacritty-ligatures { };
  amdgpu-clocks = pkgs.callPackage ./amdgpu-clocks { };
  papermc-experimental = pkgs.callPackage ./papermc-experimental { };
  soundwire = pkgs.libsForQt5.callPackage ./soundwire { };
}
