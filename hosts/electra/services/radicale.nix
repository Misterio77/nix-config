{ config, ... }:
let
  port = "5232";
in
{
  services = {
    radicale = {
      enable = true;
      settings = {
        auth = {
          type = "htpasswd";
          htpasswd_filename = config.sops.secrets.radicale-htpasswd.path;
          htpasswd_encryption = "bcrypt";
        };
      };
    };
    nginx.virtualHosts = {
      "dav.m7.rs" = {
        forceSSL = true;
        enableACME = true;
        locations."/".proxyPass = "http://localhost:${port}";
        extraConfig = ''
          proxy_set_header  X-Script-Name /;
          proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_pass_header Authorization;
        '';
      };
    };
  };
  sops.secrets.radicale-htpasswd = {
    sopsFile = ../secrets.yaml;
    owner = config.users.users.radicale.name;
    group = config.users.users.radicale.group;
  };
}
