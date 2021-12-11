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
    database = mkOption {
      type = types.nullOr types.str;
      description = "Connection string for database.";
      default = null;
    };
    address = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Address to bind to.";
    };
    port = mkOption {
      type = types.int;
      default = 8080;
      description = "Port number to bind to.";
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open port in the firewall for the server.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.projeto-bd = {
      description = "Projeto BD";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/projeto-bd";
        Restart = "on-failure";
        User = "projetobd";
      };
      environment = {
        ROCKET_ADDRESS = cfg.address;
        ROCKET_TEMPLATE_DIR = "${cfg.package}/etc/templates";
        ROCKET_ASSETS_DIR = "${cfg.package}/etc/assets";
        ROCKET_PORT = toString cfg.port;
        ROCKET_DATABASES = ''{database={url="${cfg.database}"}}'';
      };
    };

    users = {
      users.projetobd = {
        description = "Projeto BD service user";
        isSystemUser = true;
        group = "projetobd";
      };
      groups.projetobd = { };
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
