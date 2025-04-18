{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.paste-misterio-me.nixosModules.server];

  services = {
    paste-misterio-me = {
      enable = true;
      package = pkgs.inputs.paste-misterio-me.server;
      database.createLocally = true;
      environmentFile = config.sops.secrets.paste-misterio-me-secrets.path;
      port = 8082;
      maxBodySize = "30MiB";
    };

    nginx.virtualHosts."paste.misterio.me" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        client_max_body_size 30M;
      '';
      locations."/".proxyPass = "http://localhost:${toString config.services.paste-misterio-me.port}";
    };
  };

  sops.secrets.paste-misterio-me-secrets = {
    owner = "paste";
    group = "paste";
    sopsFile = ../secrets.yaml;
  };
}
