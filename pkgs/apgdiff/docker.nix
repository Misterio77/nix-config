{ pkgs, ... }:

let
  apgdiff = pkgs.callPackage ./default.nix { };
in pkgs.dockerTools.buildLayeredImage {
  name = "apgdiff";
  tag = "latest";
  contents = apgdiff;
  config.Entrypoint = [ "apgdiff" ];
}
