{config, ...}: {
  services.gns3-server = {
    enable = true;
    settings.Server = {
      host = "0.0.0.0";
      port = 3080;
    };
    dynamips.enable = true;
    ubridge.enable = true;
    vpcs.enable = true;
  };

  services.nginx.virtualHosts."gns3.m7.rs" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:3080";
      proxyWebsockets = true;
      basicAuthFile = config.sops.secrets.gns3-password.path;
    };
  };

  sops.secrets.gns3-password = {
    owner = "nginx";
    group = "nginx";
    sopsFile = ../secrets.yaml;
  };
}
