{ hostname, ... }: {
  imports = [ ./lutris.nix ./steam.nix ./polymc.nix ./runescape.nix ];
}
