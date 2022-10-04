{
  services.nginx.virtualHosts = {
    "home.m7.rs" = {
      forceSSL = true;
      default = true;
      enableACME = true;
      locations."/".root = "/srv/files";
    };
  };
}
