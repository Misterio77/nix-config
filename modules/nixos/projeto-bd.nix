{ config, lib, pkgs, ... }:

with lib;
let cfg = config.services.projeto-bd;

in {
  options.services.projeto-bd = {
    enable = mkEnableOption "Projeto BD";
    package = mkOption {
      type = types.package;
      default = pkgs.projeto-bd;
      defaultText = "pkgs.projeto-bd";
      description = ''
        The package implementing projeto bd
      '';
    };
    tlsChain = mkOption {
      type = types.nullOr types.path;
      description = "File path containing certificate chain.";
      default = null;
    };
    tlsKey = mkOption {
      type = types.nullOr types.path;
      description = "File path containing private key.";
      default = null;
    };
    database = mkOption {
      type = types.nullOr types.str;
      description = "Connection string for database.";
      default = null;
    };
    port = mkOption {
      type = types.int;
      default = if (cfg.tlsChain && cfg.tlsKey) then 443 else 80;
      description = "Port number to bind to.";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open ports in th firewall for the server.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.projeto-bd = {
      description = "Projeto BD";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/projeto-bd";
        Restart = "on-failure";
      };
      environment = {
        ROCKET_TEMPLATE_DIR = "${cfg.package}/etc/projeto-bd/templates";
        ROCKET_ASSETS_DIR = "${cfg.package}/etc/projeto-bd/assets";
        ROCKET_PORT = toString cfg.port;
        ROCKET_DATABASES = ''
          {database={url="${cfg.database}"}}
        '';
        ROCKET_TLS = mkIf (cfg.tlsChain != null && cfg.tlsKey != null) ''
          {certs="${cfg.tlsChain}",key="${cfg.tlsKey}"}
        '';
      };
    };
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
