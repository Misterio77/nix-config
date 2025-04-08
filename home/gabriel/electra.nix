{pkgs, lib, config, inputs, ...}: {
  imports = [
    ./global
    ./features/desktop/hyprland
    ./features/pass
  ];
  home.persistence."/persist/${config.home.homeDirectory}" = lib.mkForce {};
  home.username = "gabriel";
  home.packages = [
    pkgs.juju
    pkgs.sshuttle
    pkgs.charmcraft
    pkgs.lxd-lts
  ];

  targets.genericLinux.enable = true;
  nixGL = {
    packages = inputs.nix-gl.packages;
    defaultWrapper = "mesa";
    installScripts = ["mesa"];
    vulkan.enable = true;
  };

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
  wallpaper = pkgs.inputs.themes.wallpapers.aenami-northern-lights;
}
