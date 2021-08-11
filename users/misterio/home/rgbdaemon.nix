{ config, pkgs, ... }:
let colors = config.colorscheme.colors;
in {
  imports = [ ../../../modules/rgbdaemon.nix ];
  services.rgbdaemon = {
    enable = true;
    package = pkgs.rgbdaemon;
    interval = 0.8;
    daemons = {
      swayWorkspaces = true;
      swayLock = true;
      mute = true;
      tty = true;
      player = true;
    };
    colors = {
      background = "${colors.base00}";
      foreground = "${colors.base05}";
      secondary = "${colors.base0B}";
      tertiary = "${colors.base0E}";
      quaternary = "${colors.base05}";
    };
    keyboard = {
      device = "/dev/input/ckb1/cmd";
      highlighted = [ "h" "j" "k" "l" "w" "a" "s" "d" "m3" "g11" "profswitch" ];
    };
    mouse = {
      device = "/dev/input/ckb2/cmd";
      dpi = 750;
      highlighted = [ "wheel" "thumb" ];
    };
  };
}
