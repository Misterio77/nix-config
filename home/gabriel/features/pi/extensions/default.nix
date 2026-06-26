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
in {
  programs.pi-coding-agent = {
    settings = {
      extensions = [
        gabsExtensions
        piLlamaCpp
      ];
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
