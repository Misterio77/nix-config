{ config, pkgs, ... }:
let
  colors = config.colorscheme.colors;
in {
  imports = [
    ../../../modules/rgbdaemon.nix
  ];
  services.rgbdaemon = {
    enable = true;
    package = pkgs.stdenv.mkDerivation {
      name = "rgbdaemon";
      src = pkgs.fetchFromGitHub {
        owner = "Misterio77";
        repo = "rgbdaemon";
        rev = "822fafa2a0fe825d63d694befdf226f836bd40a4";
        sha256 = "1p1nqpfyxf0imhc7myccfs3587mks57mhfvfsm3rh0iz1798cqwv";
      };
      propagatedBuildInputs = with pkgs; [ pastel makeWrapper ];
      dontBuild = true;
      dontConfigure = true;
      installPhase = ''
        install -Dm 0755 $src/rgbdaemon.sh $out/bin/rgbdaemon
      '';
    };
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
