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
      compaction = {
        enabled = true;
        keepRecentTokens = 20000;
        reserveTokens = 16384;
      };
      enabledModels = [
        "gpt-5.5"
        "gpt-5.4"
        "claude-opus-4-8"
        "claude-sonnet-4-6"
        "claude-haiku-4-5"
      ];
    };
    keybindings = {
      "app.editor.external" = ["alt+e"];
    };
  };
  home.sessionVariables.PI_OFFLINE = true;
}
