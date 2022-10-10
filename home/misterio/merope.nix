{ inputs, ... }: {
  imports = [ ./global ];
  colorscheme = inputs.nix-colors.colorSchemes.nord;
}
