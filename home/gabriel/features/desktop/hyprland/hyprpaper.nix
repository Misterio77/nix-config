{config, ...}: {
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = {
        monitor = ""; # All monitors
        path = "${config.wallpaper}";
      };
    };
  };
}
