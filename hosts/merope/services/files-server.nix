{
  services.nginx.virtualHosts = {
    "merope.m7.rs" = {
      forceSSL = true;
      enableACME = true;
      locations."/".root = "/srv/files";
    };
  };
}
