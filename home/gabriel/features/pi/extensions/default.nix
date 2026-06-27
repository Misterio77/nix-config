{
  pkgs,
  lib,
  ...
}: let
  gabsExtensions = pkgs.buildPiExtension {
    pname = "pi-extensions";
    version = "unstable";
    src = ./gabs-extensions;
    npmDeps = pkgs.importNpmLock {npmRoot = ./gabs-extensions;};
    npmConfigHook = pkgs.importNpmLock.npmConfigHook;
  };
  piLlamaCpp = pkgs.buildPiExtension {
    pname = "pi-llama-cpp";
    version = "0.7.2";
    src = pkgs.fetchFromGitHub {
      owner = "gsanhueza";
      repo = "pi-llama-cpp";
      tag = "0.7.2";
      hash = "sha256-7ibKGmkzKwnn3fLQvwQKIlUQ3Fil1IeOC5ixRXsStjY=";
    };
    dontNpmInstall = true;
  };
  piClaudeBridge = pkgs.buildPiExtension {
    pname = "pi-claude-bridge";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "elidickinson";
      repo = "pi-claude-bridge";
      rev = "0c0feef83284b71a7cf2b5779e86ca2e8f75ce4c";
      hash = "sha256-N6hRLcbOlQyQ0coP6YTqn1k5JQlwP/qx/m8tWfySxyI=";
    };
    npmDepsHash = "sha256-cE6NKQZFwZxyr1MjbT8FXlrNyVwMxbN5mHAynmSJEVA=";
  };
in {
  programs.pi-coding-agent = {
    settings = {
      extensions = [
        gabsExtensions
        piLlamaCpp
        piClaudeBridge
      ];
      # web_fetch (gabsExtensions) shells out to pandoc for HTML->Markdown; pin
      # the store path here rather than relying on the runtime PATH.
      web.pandocPath = lib.getExe pkgs.pandoc;
      gondolin = {
        qemuPath = lib.getExe pkgs.qemu;
        httpProxy = {
          allowedHosts = ["api.github.com" "firefly.m7.rs"];
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
  };
  home.file.".pi/agent/claude-bridge.json".text = builtins.toJSON {
    askClaude.enabled = false;
    provider = {
      plan = "max";
      stripctMcpConfig = true;
      pathToClaudeCodeExecutable = lib.getExe pkgs.claude-code;
    };
  };
}
