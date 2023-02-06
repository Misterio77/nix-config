{ config, pkgs, ... }:
{
  sops.secrets.cache-sig-key = {
    sopsFile = ../secrets.yaml;
  };

  services = {
    nix-serve = {
      enable = true;
      secretKeyFile = config.sops.secrets.cache-sig-key.path;
      # TODO: temporary fix for NixOS/nix#7704
      package = pkgs.nix-serve.override { nix = pkgs.nixVersions.nix_2_12; };
    };
    nginx.virtualHosts."cache.m7.rs" = {
      forceSSL = true;
      enableACME = true;
      locations."/".extraConfig = ''
        proxy_pass http://localhost:${toString config.services.nix-serve.port};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}
