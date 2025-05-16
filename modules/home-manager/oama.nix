{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.oama;
  settingsFormat = pkgs.formats.json {};
  settingsFile = settingsFormat.generate "oama" cfg.settings;
in {
  options.programs.oama = {
    enable = lib.mkEnableOption "oama";
    settings = lib.mkOption {
      type = settingsFormat.type;
      default = {};
    };
    package = lib.mkOption {
      readOnly = true;
      type = lib.types.package;
      default = pkgs.writeShellApplication {
        name = "oama";
        runtimeInputs = [pkgs.oama config.programs.password-store.package pkgs.gnused pkgs.libsecret];
        text = ''
          oama --config <(sed "s/@CLIENT_SECRET@/$(pass oama/google_client_secret)/" "${settingsFile}") "$@"
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [cfg.package];
    };
  };
}
