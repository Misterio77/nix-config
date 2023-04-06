{ config, inputs, ... }:
let
  inherit (config.networking) hostName;
in
{
  system.autoUpgrade = {
    enable = true;
    dates = "hourly";
    flags = [
      "--refresh"
      "--override-input dark-mode ${inputs.dark-mode.outPath}" # Keep dark-mode
    ];
    flake = "git://m7.rs/nix-config?ref=release-${hostName}";
  };
}
