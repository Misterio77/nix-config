{ hostname, ... }: {
  imports = [ ./lutris.nix ./steam.nix ./polymc.nix ]
    ++ (if hostname == "atlas" then [
    ./osu.nix
    # ./runescape.nix
  ] else
    [ ]);
}
