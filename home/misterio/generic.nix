{ lib, ... }:
{
  imports = [ ./global ];
  # Disable impermanence
  home.persistence = lib.mkForce { };
}
