{config, nixosConfig, lib, ...}: {
  xdg.desktopEntries.opencode = {
    name = "Opencode";
    genericName = "AI CLI Assistant";
    comment = "Terminal-based AI coding assistant";
    exec = "opencode" + (lib.optionalString nixosConfig.services.opencode.enable " attach localhost:${toString nixosConfig.services.opencode.port}") + " -c";
    icon = "terminal";
    terminal = true;
    categories = ["Development" "ConsoleOnly"];
    mimeType = ["x-scheme-handler/opencode"];
    type = "Application";
  };

  xdg.mimeApps.defaultApplications."x-scheme-handler/opencode" = "opencode.desktop";

  programs.opencode = {
    enable = true;
    tui = {
      theme = "nix";
      keybinds = {editor_open = "alt+e";};
    };
    themes.nix.theme = import ./theme.nix {inherit (config) colorscheme;};
  };
}
