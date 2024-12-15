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
      gamescope = pkgs.gamescope.overrideAttrs (_: {
        NIX_CFLAGS_COMPILE = ["-fno-fast-math"];
      });
      gameScopeEnable = true;
      gameScopeArgs = [
        "--fullscreen"
        "--expose-wayland"
        "--force-grab-cursor"
        "--force-windows-fullscreen"
        "--prefer-output ${monitor.name}"
        "--output-width ${toString monitor.width}"
        "--output-height ${toString monitor.height}"
        "--framerate-limit ${toString monitor.refreshRate}"
      ];
      preCommands = ''
        export MESA_SHADER_CACHE_DIR="$WINEPREFIX/mesa_cache"
        export MESA_SHADER_CACHE_MAX_SIZE=10G
      '';
    })
  ];
}
