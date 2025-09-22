{pkgs, ...}: {
  programs.steam = {
    enable = true;
    gamescopeSession = {
      enable = true;
      steamArgs = ["-tenfoot" "-pipewire-dmabuf" "-steamos3"];
    };
    extraPackages = [
      # Command executed when using "Exit to Desktop" in '-steamos3' mode
      (pkgs.writeShellScriptBin "steamos-session-select" ''
        /usr/bin/env steam -shutdown
      '')
    ];
  };
}
