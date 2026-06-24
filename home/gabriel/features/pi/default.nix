{
  imports = [
    ./theme.nix
    ./extensions.nix
  ];

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
        "openai-codex/gpt-5.3-codex-spark"
      ];
      enableInstallTelemetry = false;
      enableAnalytics = false;
    };
    keybindings = {
      "app.editor.external" = ["alt+e"];
    };
  };
  home.sessionVariables.PI_SKIP_VERSION_CHECK = true;
  home.file.".pi/agent/skills".source = ./skills;
}
