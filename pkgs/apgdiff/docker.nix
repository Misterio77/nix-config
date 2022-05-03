{ pkgs }:

let
  apgdiff = pkgs.apgdiff.override { jre = pkgs.jre_minimal; };
in pkgs.dockerTools.buildLayeredImage {
  name = "apgdiff";
  tag = "latest";
  contents = apgdiff;
  config.Entrypoint = [ "apgdiff" ];
}
