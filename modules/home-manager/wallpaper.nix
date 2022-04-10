{ lib, ... }:
let inherit (lib) types mkOption;
in
{
  options.wallpaper = mkOption {
    type = types.path;
    default = "";
    description = ''
      Wallpaper path
    '';
  };
}
