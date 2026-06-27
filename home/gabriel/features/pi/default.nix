{
  imports = [
    ./theme.nix
    ./extensions
    ./prompts
    ./skills
  ];

  programs.pi-coding-agent = {
    enable = true;
    context = ./context.md;
    settings = {
      llamaServerUrl = "http://llm.m7.rs";
      compaction = {
        enabled = true;
        keepRecentTokens = 20000;
        reserveTokens = 16384;
      };
      defaultModel = "gpt-5.5";
      enabledModels = [
        "gpt-5.5"
        "claude-opus-4-8"
        "qwen3.6"
        "gemma-4"
      ];
    };
    keybindings = {
      "app.editor.external" = ["alt+e"];
    };
  };
  home.sessionVariables.PI_OFFLINE = true;
}
