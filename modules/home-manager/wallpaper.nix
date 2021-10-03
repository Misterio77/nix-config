{ lib, ... }:

with lib;

{
  options.wallpaper = mkOption {
    type = types.path;
    default = "";
    description = ''
      Wallpaper path
    '';
  };
}
