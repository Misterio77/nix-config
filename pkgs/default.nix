{ pkgs }: {
  amdgpu-clocks = pkgs.callPackage ../pkgs/amdgpu-clocks { };
  preferredplayer = pkgs.callPackage ../pkgs/preferredplayer { };
  rgbdaemon = pkgs.callPackage ../pkgs/rgbdaemon { };
  sistemer-bot = pkgs.callPackage ../pkgs/sistemer-bot { };
  soundwire = pkgs.libsForQt5.callPackage ../pkgs/soundwire { };
  wallpapers = pkgs.callPackage ../pkgs/wallpapers { };
  zenity-askpass = pkgs.callPackage ../pkgs/zenity-askpass { };

  setscheme = pkgs.callPackage ../pkgs/setscheme { };
  setwallpaper = pkgs.callPackage ../pkgs/setwallpaper { };

  setscheme-wofi = pkgs.callPackage ../pkgs/setscheme-wofi {
    inherit (pkgs.gnome) zenity;
  };
  setwallpaper-wofi = pkgs.callPackage ../pkgs/setwallpaper-wofi {
    inherit (pkgs.gnome) zenity;
  };

  # Experimental papermc version
  papermc-experimental = pkgs.callPackage ../pkgs/papermc-experimental { };

  pass-wofi = pkgs.callPackage ../pkgs/pass-wofi {
    pass = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  };
}
