# Convert config.monitors into hyprland's format
{ lib, monitors }:
let
  inherit (builtins) concatStringsSep map toString;
in

concatStringsSep "\n" (map
  (m: ''
    monitor=${m.name},${toString m.width}x${toString m.height}@${toString m.refreshRate},${toString m.x}x${toString m.y},${if m.enabled then "1" else "0"}
    ${lib.optionalString (m.workspace != null)"workspace=${m.name},${m.workspace}"}
  '')
  monitors
)


