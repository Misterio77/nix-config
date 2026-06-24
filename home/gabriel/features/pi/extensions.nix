{pkgs, lib, ...}: {
  programs.pi-coding-agent = {
    settings = {
      extensions = [
        (pkgs.buildNpmPackage {
          pname = "custom-extensions";
          version = "0-unstable";
          src = ./custom-extensions;
          npmDepsHash = "sha256-odIhyMMSPBTtskV52CTEBGpMPVzUkBFLj6n+9JZCNZo=";
          npmDepsFetcherVersion = 2;
          dontNpmBuild = true;
          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp -r . $out/
            runHook postInstall
          '';
        })
      ];
      gondolin = {
        qemuPath = lib.getExe pkgs.qemu;
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
  };
}
