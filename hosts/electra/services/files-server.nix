{
  services.nginx.virtualHosts = {
    "files.m7.rs" = {
      default = true;
      forceSSL = true;
      enableACME = true;
      locations."/".root = "/srv/files";
    };
    "f.m7.rs" = {
      forceSSL = true;
      enableACME = true;
      locations."/".return = "302 https://files.m7.rs$request_uri";
    };
    "files.misterio.me" = {
      forceSSL = true;
      enableACME = true;
      locations."/".return = "302 https://files.m7.rs$request_uri";
    };
  };
}
