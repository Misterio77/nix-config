{
  imports = [
    ./theme.nix
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
      ];
      enableInstallTelemetry = false;
      enableAnalytics = false;
      gondolin = {
        http-proxy = {
          allowedHosts = ["api.github.com"];
          secrets = {
            GITHUB_TOKEN = {
              hosts = ["api.github.com"];
              cmd = "gh auth token";
            };
          };
        };
      };
    };
  };
  home.sessionVariables.PI_SKIP_VERSION_CHECK = true;
  home.file.".agents/skills".source = ./skills;
  home.file.".agents/extensions".source = ./extensions;
}
