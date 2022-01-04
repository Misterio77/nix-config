{ hostname, ... }: {
  imports = [ ./lutris.nix ./steam.nix ./multimc.nix ]
    ++ (if hostname == "atlas" then [
      ./osu.nix
      ./runescape.nix
    ] else
      [ ]);
}
