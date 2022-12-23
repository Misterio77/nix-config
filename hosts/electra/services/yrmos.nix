{ config, inputs, pkgs, ... }: {
  imports = [
    inputs.yrmos.nixosModules.default
  ];

  services = {
    yrmos = {
      enable = true;
      package = inputs.yrmos.packages.${pkgs.system}.default;
      port = 8083;
      user = "yrmos";
      environmentFile = config.sops.secrets.yrmos-secrets.path;
    };

    nginx.virtualHosts."yrmos.m7.rs" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass =
        "http://localhost:${toString config.services.yrmos.port}";
    };
  };

  sops.secrets.yrmos-secrets = {
    owner = "yrmos";
    group = "yrmos";
    sopsFile = ../secrets.yaml;
  };
}
