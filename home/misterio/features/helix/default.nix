{ config, ... }:
let
  inherit (config) colorscheme;
in
{
  programs.helix = {
    enable = true;
    settings = {
      theme = "${colorscheme.slug}";
      editor = {
        line-number = "absolute";
        indent-guides.render = true;
      };
    };
    themes = import ./theme.nix { inherit colorscheme; };
  };
}
