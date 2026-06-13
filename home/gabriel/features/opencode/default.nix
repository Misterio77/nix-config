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

  home.persistence = {
    "/persist".directories = [
      ".config/opencode/skills/gabs-info" # Private info about myself
      ".config/opencode/skills/firefly" # Guidance on how to use firefly to manage my finances, includes sensitive data
      ".config/opencode/skills/lumis" # Info on my card printing sidegig
    ];
  };

  programs.opencode = {
    enable = true;
    settings = {
      provider.deepseek.options = {
        apiKey = "{file:/run/secrets/deepseek-apikey}";
      };
      autoupdate = false;
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
    skills = {
      gabs-tools = ./skills/gabs-tools;
      jujutsu = ./skills/jujutsu;
    };
  };
}
