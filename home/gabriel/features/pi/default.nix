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
        httpProxy = {
          allowedHosts = ["api.github.com"  "firefly.m7.rs"];
          secrets = {
            GITHUB_TOKEN = {
              hosts = ["api.github.com"];
              cmd = "gh auth token";
            };
            FIREFLY_TOKEN = {
              hosts = ["firefly.m7.rs"];
              cmd = "pass firefly.m7.rs/pi-pat";
            };
          };
        };
      };
    };
    keybindings = {
      "app.editor.external" = ["alt+e"];
    };
  };
  home.sessionVariables.PI_SKIP_VERSION_CHECK = true;

  home.file.".pi/agent/skills".source = ./skills;
  home.file.".pi/agent/extensions".source = pkgs.buildNpmPackage {
    pname = "pi-extensions";
    version = "0-unstable";
    src = ./extensions;
    npmDepsHash = "sha256-odIhyMMSPBTtskV52CTEBGpMPVzUkBFLj6n+9JZCNZo=";
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
