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
    tui = {
      theme = "nix";
      keybinds = {
        editor_open = "alt+e";
      };
    };
    themes.nix.theme = import ./theme.nix {inherit (config) colorscheme;};
    settings = {
      autoupdate = false;
      provider.deepseek.options.apiKey = "{file:${osConfig.sops.secrets.deepseek-apikey.path}}";
      provider.openai.options.apiKey = "{file:${osConfig.sops.secrets.openai-free-apikey.path}}";

      model = "deepseek/deepseek-v4-flash";
      instructions = [osConfig.sops.secrets.gabs-info.path];
    };
    context = ./context.md; # Main context
    agents = ./agents;
    skills = {
      jujutsu = ./skills/jujutsu; # From https://github.com/mtaran/jj-guide
      gabs-tools = ./skills/gabs-tools;
      edit-skills = ./skills/edit-skills;
      nix-shell = ./skills/nix-shell;
      screenshot = ./skills/screenshot;
      firefly = ./skills/firefly;
      lumis = ./skills/lumis;
      browser = ./skills/browser;
    };
  };

  xdg.configFile."opencode/skills/firefly/resources/private.md".source = "${config.lib.file.mkOutOfStoreSymlink osConfig.sops.secrets.skill-firefly-private.path}";
  xdg.configFile."opencode/skills/lumis/resources/private.md".source = "${config.lib.file.mkOutOfStoreSymlink osConfig.sops.secrets.skill-lumis-private.path}";
}
