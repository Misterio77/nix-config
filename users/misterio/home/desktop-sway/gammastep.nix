{
  services.gammastep = {
    enable = true;
    provider = "geoclue2";
    settings = {
      general.adjustment-method = "wayland";
    };
  };
}
