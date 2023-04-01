{ config, ... }:
let
  inherit (config.networking) hostName;
in
{
  system.autoUpgrade = {
    enable = true;
    dates = "hourly";
    flags = [ "--refresh" ];
    flake = "git://m7.rs/nix-config?ref=release-${hostName}";
  };
}
