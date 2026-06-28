{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.services.codex-openai-proxy;
in {
  options.services.codex-openai-proxy = {
    enable = lib.mkEnableOption "the OpenAI-compatible proxy for a ChatGPT Codex subscription";

    package = lib.mkPackageOption pkgs "codex-openai-proxy" {};

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address the proxy binds to.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8788;
      description = "Port the proxy listens on.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/codex-openai-proxy";
      description = ''
        Path to an environment file, read by systemd as root before privileges
        are dropped. Must provide `CODEX_REFRESH_TOKEN`, and may also set
        `CODEX_CLIENT_ID` and `CODEX_API_KEY`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.codex-openai-proxy = {
      description = "OpenAI-compatible proxy for the ChatGPT Codex subscription";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      environment = {
        CODEX_HOST = cfg.host;
        CODEX_PORT = toString cfg.port;
      };
      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = 10;
        # Hardening
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
      };
    };
  };
}
