{ lib, config, pkgs, ... }:
let
  cfg = config.services.sitespeedio;
  format = pkgs.formats.json { };
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

    dataDir = lib.mkOption {
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

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = format.type;
        options = {
          browser = lib.mkOption {
            type = lib.types.str;
            default = "firefox";
            example = "chrome";
          };
          outputFolder = lib.mkOption {
            type = lib.types.str;
            default = cfg.dataDir;
            defaultText = "cfg.dataDir";
          };
          browsertime = {
            headless = lib.mkOption {
              type = lib.types.bool;
              default = true;
            };
          };
        };
      };
      default = { };
      description = lib.mdDoc ''
        Configuration for sitespeedio, see
        <https://www.sitespeed.io/documentation/sitespeed.io/configuration/>
        for available options. The value here will be directly transformed to
        JSON and passed as `--config` to the program.
      '';
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [];
      description = lib.mdDoc ''
        Extra command line arguments to pass to the program.
      '';
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
      serviceConfig = {
        WorkingDirectory = cfg.dataDir;
        User = cfg.user;
      };
      preStart = "chmod u+w -R ${cfg.dataDir}"; # Make sure things are writable
      script = ''
        ${cfg.package}/bin/sitespeedio \
          --config ${format.generate "sitespeed.json" cfg.settings} \
          ${lib.escapeShellArgs cfg.extraArgs} \
          ${builtins.toFile "urls.txt" (lib.concatLines cfg.urls)}
      '';
    };

    users = {
      extraUsers.${cfg.user} = {
        isSystemUser = true;
        group = cfg.user;
        home = cfg.dataDir;
        createHome = true;
        homeMode = "755";
      };
      extraGroups.${cfg.user} = { };
    };
  };
}
