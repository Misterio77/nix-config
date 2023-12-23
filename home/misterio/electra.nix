{ inputs, outputs, lib, ... }: let
  inherit (inputs.nix-colors) colorSchemes;
in {
  imports = [
    ./global
    ./features/desktop/wireless
    ./features/desktop/hyprland
    ./features/pass
  ];

  colorscheme = lib.mkDefault colorSchemes.silk-dark;
  specialisation = {
    light.configuration.colorscheme = colorSchemes.silk-light;
  };

  monitors = [
    {
      name = "HDMI-A-1";
      width = 1920;
      height = 1080;
      workspace = "2";
      x = 0;
    }
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      workspace = "1";
      x = 1920;
      primary = true;
    }
  ];

  # programs.git.userEmail = "gabriel@zoocha.com";
}
