{ config, ... }:
let
  inherit (config.networking) hostName;
in
{
  system.autoUpgrade = {
    enable = true;
    dates = "hourly";
    flake = "github:misterio77/nix-config/release-${hostName}";
  };
}
