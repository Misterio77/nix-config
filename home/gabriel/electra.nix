{pkgs, lib, config, ...}: {
  imports = [
    ./global
    ./features/desktop/hyprland
    ./features/pass
  ];
  home.persistence."/persist/${config.home.homeDirectory}" = lib.mkForce {};
  home.username = "gabriel";
  home.packages = [
    pkgs.inputs.nix-gl.nixGLIntel
    pkgs.juju
    pkgs.sshuttle
  ];

  targets.genericLinux.enable = true;

  # Local configuration file overrides for git and SSH
  # The guys over at $WORK don't like me mentioning my work email or hostnames
  # in github :(
  programs.git.includes = [{ path = "local.conf"; }];
  programs.ssh.includes = ["local.conf"];

  monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      workspace = "1";
      primary = true;
    }
    {
      name = "HDMI-A-1";
      width = 1920;
      height = 1080;
      workspace = "2";
      position = "auto-left";
    }
  ];
  # Green
  wallpaper = pkgs.wallpapers.aenami-northern-lights;
  colorscheme.type = "rainbow";
}
