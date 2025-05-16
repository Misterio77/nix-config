{config, ...}: {
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = true;
      splash = false;
      preload = "${config.wallpaper}";
      wallpaper = ",${config.wallpaper}";
    };
  };
}
