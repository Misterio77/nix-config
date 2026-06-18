{config, ...}: {
  programs.pi-coding-agent = {
    enable = true;
    context = ./context.md;
    settings = {
      compaction = {
        enabled = true;
        keepRecentTokens = 20000;
        reserveTokens = 16384;
      };
      defaultProvider = "openai-codex";
      defaultModel = "gpt-5.5";
      defaultThinkingLevel = "medium";
      enabledModels = [
        "openai-codex/gpt-5.5"
        "openai-codex/gpt-5.4-mini"
      ];
      theme = config.colorscheme.mode;
    };
  };

  home.file.".agents/skills".source = ./skills;
}
