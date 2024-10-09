{pkgs, ...}: let
  toYAML = pkgs.lib.generators.toYAML {};
in {
  programs.carapace.enable = true;
  xdg.configFile."carapace/bridges.yaml".text = toYAML {
    nh = "fish";
    hyprctl = "fish";
    pass = "fish";
    nix = "fish";
    man = "fish";
    juju = "bash";
  };
}
