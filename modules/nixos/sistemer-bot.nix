{ config, lib, pkgs, ... }:

with lib;
let cfg = config.services.sistemer-bot;

in {
  options.services.sistemer-bot = {
    enable = mkEnableOption "Sistemer Bot";
    package = mkOption {
      type = types.package;
      default = pkgs.sistemer-bot;
      defaultText = "pkgs.sistemer-bot";
      description = ''
        The package implementing sistemer bot
      '';
    };
    tokenFile = mkOption {
      type = types.nullOr types.path;
      description = "File path containing telegram token to use.";
      default = null;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.sistemer-bot = {
      description = "Sistemer Bot";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/sistemer-bot";
        Restart = "on-failure";
        EnvironmentFile = mkIf (cfg.tokenFile != null) "${cfg.tokenFile}";
      };
    };
  };
}
