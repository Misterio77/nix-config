{
  pkgs,
  lib,
  config,
  ...
}: let
  monitor = lib.head (lib.filter (m: m.primary) config.monitors);
in {
  home.packages = [
    (pkgs.inputs.nix-gaming.star-citizen.override {
      disableEac = false;
      useUmu = true;
      gameScopeEnable = true;
      gameScopeArgs = [
        "--force-grab-cursor"
        "--output-width ${toString monitor.width}"
        "--output-height ${toString monitor.height}"
        "--framerate-limit ${toString monitor.refreshRate}"
        "--prefer-output ${monitor.name}"
      ];
    })
  ];
}
