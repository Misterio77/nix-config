{pkgs, ...}: {
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

  home.file.".pi/agent/skills".source = ./skills;
  home.file.".pi/agent/extensions".source = pkgs.buildNpmPackage {
    pname = "pi-extensions";
    version = "0-unstable";
    src = ./extensions;
    npmDepsHash = "sha256-u4B5khW2gL4hcu1KUR/xa7l1eClJfk1Ab6JiFZEX69Q=";
    npmDepsFetcherVersion = 2;
    dontNpmBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r . $out/
      runHook postInstall
    '';
  };
  home.packages = [pkgs.qemu];
}
