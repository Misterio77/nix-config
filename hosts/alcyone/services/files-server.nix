{config, ...}: let
  files = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      root = "/srv/files";
      extraConfig = ''
        allow 127.0.0.1;
        allow ::1;
        allow ${config.services.headscale.settings.prefixes.v4};
        allow ${config.services.headscale.settings.prefixes.v6};
        deny all;
      '';
    };
  };
in {
  services.nginx.virtualHosts = {
    "files.m7.rs" = files;
    "f.m7.rs" = files;
  };
}
