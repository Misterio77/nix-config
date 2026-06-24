{
  pkgs,
  lib,
  ...
}: let
  gabsExtensions = pkgs.buildNpmPackage {
    pname = "pi-extensions";
    version = "unstable";
    src = ./gabs-extensions;
    npmDepsHash = "sha256-odIhyMMSPBTtskV52CTEBGpMPVzUkBFLj6n+9JZCNZo=";
    dontNpmBuild = true;
    npmDepsFetcherVersion = 2;
    installPhase = ''
      mkdir -p $out
      cp -r . $out/
    '';
  };
in {
  programs.pi-coding-agent = {
    settings = {
      extensions = [
        gabsExtensions
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
