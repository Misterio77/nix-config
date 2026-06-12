{config, ...}: {
  xdg.desktopEntries.opencode = {
    name = "Opencode";
    genericName = "AI CLI Assistant";
    comment = "Terminal-based AI coding assistant";
    exec = "opencode";
    icon = "terminal";
    terminal = true;
    categories = [
      "Development"
      "ConsoleOnly"
    ];
    mimeType = ["x-scheme-handler/opencode"];
    type = "Application";
  };

  xdg.mimeApps.defaultApplications."x-scheme-handler/opencode" = "opencode.desktop";

  programs.opencode = {
    enable = true;
    settings = {
      provider.deepseek = {
        # Would be nice to have a api-key-cmd or similar
        apiKey = "{file:~/.config/deepseek.key}";
      };
      model = "deepseek/deepseek-v4-pro";
      small_model = "deepseek/deepseek-v4-flash";
    };
    themes.nix.theme = import ./theme.nix { inherit (config) colorscheme; };
    tui = {
      theme = "nix";
      keybinds = {
        editor_open = "alt+e";
      };
    };
    context = ./context.md;
  };
}
