{
  config,
  outputs,
  ...
}: let
  hs = outputs.nixosConfigurations.alcyone.config.services.headscale.settings.prefixes;
in {
  # codex-openai-proxy: exposes the ChatGPT Codex subscription as a local
  # Responses API endpoint for LibreChat to talk to. The refresh token is read
  # by systemd (as root) from the sops secret before privileges are dropped.
  sops.secrets.codex-refresh-token.sopsFile = ../secrets.yaml; # CODEX_REFRESH_TOKEN=...

  services.codex-openai-proxy = {
    enable = true;
    host = "127.0.0.1";
    environmentFile = config.sops.secrets.codex-refresh-token.path;
  };

  # LibreChat: only reachable on localhost; nginx fronts it (see below).
  # Uses a local mongodb (SSPL, so unfree and uncached -- hydra builds it once
  # and caches to cache.m7.rs). FerretDB 1.x was too incompatible (incomplete
  # findAndModify, breaking user registration).
  sops.secrets.librechat-creds.sopsFile = ../secrets.yaml; # CREDS_KEY, CREDS_IV, JWT_SECRET, JWT_REFRESH_SECRET

  services.librechat = {
    enable = true;
    enableLocalDB = true; # local mongodb, sets MONGO_URI
    credentialsFile = config.sops.secrets.librechat-creds.path;
    env = {
      HOST = "127.0.0.1";
      ALLOW_REGISTRATION = true;
    };
    settings = {
      version = "1.2.1";
      endpoints.custom = [
        {
          name = "Codex";
          # Bound to localhost and key-less, so a placeholder key is fine.
          apiKey = "codex-proxy";
          baseURL = "http://127.0.0.1:${toString config.services.codex-openai-proxy.port}/v1";
          # Talk the native Responses API rather than chat-completions; the
          # proxy only serves /v1/responses.
          useResponsesApi = true;
          models = {
            # Augmented at runtime from the proxy's GET /v1/models; default is
            # the required seed/fallback list (LibreChat rejects it missing).
            default = ["gpt-5.5" "gpt-5.4" "gpt-5.4-mini"];
            fetch = true;
          };
          # Title generation also goes through /v1/responses (non-streaming,
          # which the proxy reassembles).
          titleConvo = true;
          titleModel = "gpt-5.4-mini";
          modelDisplayLabel = "Codex";
        }
      ];
    };
  };

  services.nginx.virtualHosts."ai.m7.rs" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.librechat.env.PORT}";
      proxyWebsockets = true;
      # Locked to tailscale; the ACME challenge location is exempt.
      extraConfig = ''
        allow 127.0.0.1;
        allow ::1;
        allow ${hs.v4};
        allow ${hs.v6};
        deny all;
      '';
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/librechat";
      user = "librechat";
      group = "librechat";
      mode = "0700";
    }
    {
      directory = "/var/lib/mongodb";
      user = "mongodb";
      group = "mongodb";
      mode = "0700";
    }
  ];
}
