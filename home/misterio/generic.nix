{ lib, username ? "misterio", ... }:
{
  imports = [ ./global ];
  home = {
    # Overridable username
    inherit username;
    # Disable impermanence
    persistence = lib.mkForce {};
  };
}
