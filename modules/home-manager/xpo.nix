{ config, pkgs, lib, ... }:
let
  cfg = config.programs.xpo;
  package = pkgs.xpo;
in
{
  options.programs.xpo = {
    enable = lib.mkEnableOption "xpo";

    defaultServer = lib.mkOption {
      default = null;
      type = with lib.types; nullOr string;
      description = ''
        Default SSH server/endpoint to use when tunneling.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ package ];
      sessionVariables.XPO_SERVER = lib.optionalString (cfg.defaultServer != null) cfg.defaultServer;
    };
  };
}
