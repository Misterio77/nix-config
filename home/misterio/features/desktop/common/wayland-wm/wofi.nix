{ config, lib, pkgs, ... }:
let
  pass-wofi = pkgs.pass-wofi.override {
    pass = config.programs.password-store.package;
  };
in
{
  home.packages = with pkgs; [
    wofi
    pass-wofi
  ];

  xdg.configFile."wofi/config".text = ''
    image_size=48
    columns=3
    allow_images=true
    insensitive=true

    run-always_parse_args=true
    run-cache_file=/dev/null
    run-exec_search=true
  '';
}
