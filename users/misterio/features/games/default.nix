{ hostname, ... }:
{
  imports = [
    ./lutris.nix
    ./steam.nix
  ] + (if hostname == "atlas" then [
    ./multimc.nix
    ./osu.nix
    ./runescape.nix
    ./yuzu.nix
  ] else [ ]);
}
