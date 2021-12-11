{ lib, features, ... }: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
