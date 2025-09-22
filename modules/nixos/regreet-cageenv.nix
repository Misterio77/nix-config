{config, lib, pkgs, ...}: let
  inherit (lib.types) attrsOf coercedTo listOf str;
  cfg = config.programs.regreet;
in {
  options.programs.regreet = {
    cageEnv = lib.mkOption {
      type = attrsOf (coercedTo (listOf str) (lib.concatStringsSep ":") str);
      default = {};
    };
  };

  config = {
    services.greetd = let
      envVars = lib.mapAttrsToList (n: v: "\"${n}=\$${n}:${v}\"") cfg.cageEnv;
    in {
      settings.default_session.command = lib.mkOverride 999 "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.cage} ${lib.escapeShellArgs cfg.cageArgs} -- env ${toString envVars} ${lib.getExe cfg.package}";
    };
  };
}
