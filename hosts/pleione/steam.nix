{pkgs, ...}: let
  # Command executed when using "Exit to Desktop" in '-steamos3' mode
  steamos-session-select = (pkgs.writeShellScriptBin "steamos-session-select" ''
    /usr/bin/env steam -shutdown
  '');
in {
  environment.systemPackages = [steamos-session-select];
  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
      steamArgs = ["-tenfoot" "-pipewire-dmabuf" "-steamos3"];
    };
    extraPackages = [steamos-session-select];
  };
}
