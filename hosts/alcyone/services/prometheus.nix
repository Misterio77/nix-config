{
  services.prometheus = {
    enable = true;
    alertmanager = {
      enable = true;
      port = 9093;
    };
  };
}
