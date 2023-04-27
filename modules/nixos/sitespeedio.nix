{ lib, config, pkgs, ... }:
let
  cfg = config.services.sitespeedio;
in
{
  options.services.sitespeedio = {
    enable = lib.mkEnableOption "Sitespeed.io";

    user = lib.mkOption {
      type = lib.types.str;
      default = "sitespeedio";
      description = lib.mdDoc "User account under which sitespeedio runs.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.sitespeedio;
      defaultText = "pkgs.sitespeedio";
      description = lib.mdDoc "Sitespeed.io package to use.";
    };

    outputDir = lib.mkOption {
      default = "/var/lib/sitespeedio";
      type = lib.types.str;
      description = lib.mdDoc "The directory where sitespeed saves its outputs.";
    };

    period = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = lib.mdDoc ''
        Systemd calendar expression when to run. See {manpage}`systemd.time(7)`.
      '';
    };

    urls = lib.mkOption {
      type = with lib.types; listOf str;
      default = [];
      description = lib.mdDoc ''
        URLs the service should monitor.
      '';
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [];
      description = lib.mdDoc ''
        Extra command line arguments to pass to the program.
      '';
    };

    graphite = {
      enable = lib.mkEnableOption "Export metrics to graphite";
      host = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
        example = "192.168.0.10";
        description = lib.mdDoc ''
          Hostname or address where to find the graphite service.
        '';
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 9108;
        description = lib.mdDoc ''
          The port graphite is reachable on.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = cfg.urls != [];
      message = "At least one URL must be configured.";
    }];

    systemd.services.sitespeedio = {
      description = "Check website status";
      startAt = cfg.period;
      serviceConfig.User = cfg.user;
      preStart = "chmod u+w -R ${cfg.outputDir}"; # Make sure things are writable
      script = let
        args = [
          "-b=firefox"
          "--browsertime.firefox.args='-headless'"
          "--outputFolder=${cfg.outputDir}"
        ] ++ (lib.optionals cfg.graphite.enable [
          "--graphite.host=${cfg.graphite.host}"
          "--graphite.port=${toString cfg.graphite.port}"
        ]) ++ cfg.urls ++ cfg.extraArgs;
      in ''
        ${cfg.package}/bin/sitespeedio ${lib.escapeShellArgs args}
      '';
    };

    users = {
      extraUsers.${cfg.user} = {
        isSystemUser = true;
        group = cfg.user;
        home = cfg.outputDir;
        createHome = true;
        homeMode = "755";
      };
      extraGroups.${cfg.user} = { };
    };
  };
}
