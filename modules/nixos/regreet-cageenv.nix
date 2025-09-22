{config, lib, pkgs, ...}: let
  inherit (lib.types) attrsOf coercedTo listOf str pathInStore;
  cfg = config.programs.regreet;
in {
  options.programs.regreet = {
    sessionPackages = lib.mkOption {
      type = listOf pathInStore;
      default = [];
    };
    cageEnv = lib.mkOption {
      type = attrsOf (coercedTo (listOf str) (lib.concatStringsSep ":") str);
      default = {};
    };
  };

  config = {
    programs.regreet = {
      cageEnv.XDG_DATA_DIRS = lib.map (v: "${v}/share") cfg.sessionPackages;
    };

    services.greetd = let
      envVars = lib.mapAttrsToList (n: v: "\"${n}=\$${n}:${v}\"") cfg.cageEnv;
    in {
      settings.default_session.command = lib.mkOverride 999 "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.cage} ${lib.escapeShellArgs cfg.cageArgs} -- env ${toString envVars} ${lib.getExe cfg.package}";
    };
  };
}
