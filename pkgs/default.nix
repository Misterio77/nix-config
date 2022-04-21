{ pkgs }: {
  alacritty-ligatures = pkgs.callPackage ./alacritty-ligatures { };
  argononed = pkgs.callPackage ./argononed { };
  clematis = pkgs.callPackage ./clematis { };
  comma = pkgs.callPackage ./comma { };
  minicava = pkgs.callPackage ./minicava { };
  pass-wofi = pkgs.callPackage ./pass-wofi { };
  photoprism = pkgs.callPackage ./photoprism { };
  preferredplayer = pkgs.callPackage ./preferredplayer { };
  rgbdaemon = pkgs.callPackage ./rgbdaemon { };
  shellcolord = pkgs.callPackage ./shellcolord { };
  swayfader = pkgs.callPackage ./swayfader { };
  wallpapers = pkgs.callPackage ./wallpapers { };
}
