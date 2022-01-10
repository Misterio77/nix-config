{ config, lib, pkgs, ... }:

with lib;
let cfg = config.services.paste-misterio-me;

in {
  options.services.paste-misterio-me = {
    enable = mkEnableOption "paste.misterio.me";
    package = mkOption {
      type = types.package;
      default = pkgs.paste-misterio-me;
      defaultText = "pkgs.paste-misterio-me";
      description = ''
        The package implementing paste.misterio.me
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
    environmentFile = mkOption {
      type = types.nullOr types.path;
      description = "File path containing environment variables (secret key, for example) for the server";
      default = null;
    };
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open port in the firewall for the server.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.paste-misterio-me = {
      description = "paste.misterio.me";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/paste-misterio-me";
        Restart = "on-failure";
        User = "paste";
        EnvironmentFile = "${cfg.environmentFile}";
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
      users.paste = {
        description = "paste.misterio.me service user";
        isSystemUser = true;
        group = "paste";
      };
      groups.paste = { };
    };

    networking.firewall =
      mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };
  };
}
