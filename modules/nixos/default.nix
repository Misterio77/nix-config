{
  satisfactory = import ./satisfactory.nix;
  hydra-auto-upgrade = import ./hydra-auto-upgrade.nix;
  openrgb = import ./openrgb.nix;
  nix-registry-prometheus-exporter = import ./nix-registry-prometheus-exporter.nix;
  # Upstream me
  steam = import ./steam.nix;
}
