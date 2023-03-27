# Convert config.monitors into hyprland's format
{ lib, monitors }:
let enabledMonitors = lib.filter (m: m.enabled) monitors;
in

lib.concatStringsSep "\n" (lib.forEach enabledMonitors (m: ''
  monitor=${m.name},${toString m.width}x${toString m.height}@${toString m.refreshRate},${toString m.x}x${toString m.y},1
  ${lib.optionalString (m.workspace != null)"workspace=${m.name},${m.workspace}"}
''))


