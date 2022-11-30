{ config, lib, pkgs, ... }:
let
  wofi = pkgs.wofi.overrideAttrs (oa: {
    patches = (oa.patches or [ ]) ++ [
      ./wofi-run-shell.patch # Fix for https://todo.sr.ht/~scoopta/wofi/174
    ];
  });

  pass = config.programs.password-store.package;
  passEnabled = config.programs.password-store.enable;
  pass-wofi = pkgs.pass-wofi.override { inherit pass; };
in
{
  home.packages = [ wofi ] ++
    (lib.optional passEnabled pass-wofi);

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
