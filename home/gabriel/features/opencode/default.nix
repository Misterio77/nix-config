{config, ...}: {
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
