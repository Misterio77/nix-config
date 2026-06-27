{
  imports = [
    ./theme.nix
    ./extensions
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
      enabledModels = [
        "qwen3.6"
        "gemma-4"
        "gpt-5.5"
        "claude-opus-4-8"
      ];
    };
    keybindings = {
      "app.editor.external" = ["alt+e"];
    };
  };
  home.sessionVariables.PI_OFFLINE = true;
}
