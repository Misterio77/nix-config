{ config, ... }:
let
  inherit (config.networking) hostName;
in
{
  system.autoUpgrade = {
    enable = true;
    dates = "04:00";
    flake = "github:misterio77/nix-config/release-${hostName}";
  };
}
