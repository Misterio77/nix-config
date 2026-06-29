{
  pkgs,
  lib,
  osConfig,
  ...
}: let
  gabsExtensions = pkgs.buildPiExtension {
    pname = "pi-extensions";
    version = "unstable";
    src = ./gabs-extensions;
    npmDeps = pkgs.importNpmLock {npmRoot = ./gabs-extensions;};
    npmConfigHook = pkgs.importNpmLock.npmConfigHook;
  };
in {
  programs.pi-coding-agent = {
    settings = {
      extensions = [
        gabsExtensions
      ];
      webSearch = {
        braveApiKeyFile = osConfig.sops.secrets.brave_api_key.path;
        kagiSessionTokenFile = osConfig.sops.secrets.kagi_session_token.path;
      };
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
}
