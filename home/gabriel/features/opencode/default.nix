{
  config,
  osConfig,
  ...
}: {
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
      provider.deepseek.options = {
        apiKey = "{file:${osConfig.sops.secrets.deepseek-apikey.path}}";
      };
      provider.openai.options = {
        apiKey = "{file:${osConfig.sops.secrets.openai-free-apikey.path}}";
      };
      autoupdate = false;
      model = "deepseek/deepseek-v4-flash";
    };
    themes.nix.theme = import ./theme.nix {inherit (config) colorscheme;};
    tui = {
      theme = "nix";
      keybinds = {
        editor_open = "alt+e";
      };
    };
    context = ./context.md;
    agents = ./agents;
    skills = {
      # Public
      gabs-tools = ./skills/gabs-tools;
      jujutsu = ./skills/jujutsu;
      edit-skills = ./skills/edit-skills;
      # Private
      gabs-info = "${config.lib.file.mkOutOfStoreSymlink osConfig.sops.secrets.skill-gabs-info.path}";
      lumis = "${config.lib.file.mkOutOfStoreSymlink osConfig.sops.secrets.skill-lumis.path}";
      firefly = "${config.lib.file.mkOutOfStoreSymlink osConfig.sops.secrets.skill-firefly.path}";
    };
  };

  xdg.configFile."opencode/skills/firefly/scripts/expenses.py".source = ./skills/firefly/scripts/expenses.py;
}
